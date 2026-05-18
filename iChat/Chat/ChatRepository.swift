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
    
    func onAppear(
        toContact: Contact,
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
        
        // Cria listener apenas uma vez
        if listener == nil {
            listener = Firestore.firestore()
                .collection("chats")
                .document(fromId)
                .collection(toContact.uuid)
                .order(by: "timestamp", descending: true)
                .start(at: [self.messages.last?.timestamp ?? 9999999999999])
                .limit(to: 10)
                .addSnapshotListener { snapshot, _ in
                    
                    guard let changes = snapshot?.documentChanges else { return }
                    
                    for change in changes where change.type == .added {
                        let doc = change.document
                        let data = doc.data()
                        
                        let message = Message(
                            uuid: doc.documentID,
                            text: data["message"] as? String ?? "",
                            isMe: fromId == (data["fromId"] as? String ?? ""),
                            timestamp: data["timestamp"] as? UInt ?? 0
                        )
                        
                        // Evita duplicar
                        if !self.messages.contains(where: { $0.uuid == message.uuid }) {
                            
                            // Mensagem nova (timestamp maior que a primeira) → topo
                            if let firstTimestamp = self.messages.first?.timestamp,
                               message.timestamp > firstTimestamp {
                                self.messages.insert(message, at: 0)
                            } else {
                                // Mensagem antiga (paginação) → final
                                self.messages.append(message)
                            }
                        }
                    }
                    completion(self.messages, self.myName, self.myPhoto)
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
        
        // Salva para o remetente
        Firestore.firestore()
            .collection("chats")
            .document(fromId)
            .collection(toContact.uuid)
            .addDocument(data: messageData) { error in
                
                if let error = error {
                    completion(error)
                    return
                }
                
                // Atualiza last-messages do remetente
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
        
        // Salva para o destinatário
        Firestore.firestore()
            .collection("chats")
            .document(toContact.uuid)
            .collection(fromId)
            .addDocument(data: messageData) { error in
                
                if let error = error {
                    completion(error)
                    return
                }
                
                // Atualiza last-messages do destinatário
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
    }

}
