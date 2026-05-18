//
//  ChatRepository.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 18/05/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class ChatRepository {
    
    private var messages: [Message] = []
    private var listener: ListenerRegistration?
    private var myName = ""
    private var myPhoto = ""
    private var hasLoadedInitial = false
    
    func onAppear(
        limit: Int,
        toContact: Contact,
        lastMessage: Message?,
        completion: @escaping ([Message], String, String) -> Void
    ) {
        
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        
        // Busca usuário apenas uma vez
        if myName.isEmpty {
            Firestore.firestore()
                .collection("users")
                .document(fromId)
                .getDocument { snapshot, _ in
                    if let data = snapshot?.data() {
                        self.myName = data["name"] as? String ?? ""
                        self.myPhoto = data["profileUrl"] as? String ?? ""
                    }
                }
        }
        
        // PRIMEIRA CARGA: usa getDocuments (não listener)
        if !hasLoadedInitial {
            hasLoadedInitial = true
            
            Firestore.firestore()
                .collection("chats")
                .document(fromId)
                .collection(toContact.uuid)
                .order(by: "timestamp", descending: true)
                .limit(to: limit)
                .getDocuments { snapshot, _ in
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    self.messages = documents.map { doc in
                        let data = doc.data()
                        return Message(
                            uuid: doc.documentID,
                            text: data["message"] as? String ?? "",
                            isMe: fromId == (data["fromId"] as? String ?? ""),
                            timestamp: data["timestamp"] as? UInt ?? 0
                        )
                    }
                    
                    completion(self.messages, self.myName, self.myPhoto)
                    
                    // Depois da primeira carga, inicia o listener para novas mensagens
                    self.startListener(fromId: fromId, toId: toContact.uuid, completion: completion)
                }
            
            return
        }
        
        // PAGINAÇÃO: carrega mais mensagens antigas
        guard let lastTimestamp = lastMessage?.timestamp else { return }
        
        Firestore.firestore()
            .collection("chats")
            .document(fromId)
            .collection(toContact.uuid)
            .order(by: "timestamp", descending: true)
            .start(after: [lastTimestamp])
            .limit(to: limit)
            .getDocuments { snapshot, _ in
                
                guard let documents = snapshot?.documents else { return }
                
                let newMessages = documents.map { doc -> Message in
                    let data = doc.data()
                    return Message(
                        uuid: doc.documentID,
                        text: data["message"] as? String ?? "",
                        isMe: fromId == (data["fromId"] as? String ?? ""),
                        timestamp: data["timestamp"] as? UInt ?? 0
                    )
                }
                
                self.messages.append(contentsOf: newMessages)
                completion(self.messages, self.myName, self.myPhoto)
            }
    }
    
    
    // LISTENER: apenas para novas mensagens
    private func startListener(
        fromId: String,
        toId: String,
        completion: @escaping ([Message], String, String) -> Void
    ) {
        
        guard listener == nil else { return }
        
        // Pega o timestamp da mensagem mais recente que você já tem
        let lastTimestamp = self.messages.first?.timestamp ?? 0
        
        listener = Firestore.firestore()
            .collection("chats")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp", descending: false)
            .whereField("timestamp", isGreaterThan: lastTimestamp)  // ← só mensagens NOVAS
            .addSnapshotListener { snapshot, _ in
                
                guard let change = snapshot?.documentChanges.first else { return }
                
                if change.type == .added {
                    let doc = change.document
                    let data = doc.data()
                    
                    let message = Message(
                        uuid: doc.documentID,
                        text: data["message"] as? String ?? "",
                        isMe: fromId == (data["fromId"] as? String ?? ""),
                        timestamp: data["timestamp"] as? UInt ?? 0
                    )
                    
                    // Só adiciona se for mensagem nova (não duplica)
                    if !self.messages.contains(where: { $0.uuid == message.uuid }) {
                        self.messages.insert(message, at: 0)
                        completion(self.messages, self.myName, self.myPhoto)
                    }
                }
            }
    }
    
    
    func sendMessage(
        toContact: Contact,
        message: String,
        completion: @escaping (Error?) -> Void
    ) {
        
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        
        let timestamp = UInt(Date().timeIntervalSince1970)
        
        let messageData: [String: Any] = [
            "message": message,
            "fromId": fromId,
            "toId": toContact.uuid,
            "timestamp": timestamp
        ]
        
        Firestore.firestore()
            .collection("chats")
            .document(fromId)
            .collection(toContact.uuid)
            .addDocument(data: messageData) { error in
                
                if let error = error {
                    completion(error)
                    return
                }
                
                Firestore.firestore()
                    .collection("last-messages")
                    .document(fromId)
                    .collection("contacts")
                    .document(toContact.uuid)
                    .setData([
                        "uuid": toContact.uuid,
                        "name": toContact.name,
                        "profileUrl": toContact.profileUrl,
                        "timestamp": timestamp,
                        "lastMessage": message
                    ])
            }
        
        Firestore.firestore()
            .collection("chats")
            .document(toContact.uuid)
            .collection(fromId)
            .addDocument(data: messageData) { error in
                
                if let error = error {
                    completion(error)
                    return
                }
                
                Firestore.firestore()
                    .collection("last-messages")
                    .document(toContact.uuid)
                    .collection("contacts")
                    .document(fromId)
                    .setData([
                        "uuid": fromId,
                        "name": self.myName,
                        "profileUrl": self.myPhoto,
                        "timestamp": timestamp,
                        "lastMessage": message
                    ])
                
                completion(nil)
            }
    }
    
    
    func removeListener() {
        listener?.remove()
        listener = nil
        hasLoadedInitial = false
        messages.removeAll()
    }
}
