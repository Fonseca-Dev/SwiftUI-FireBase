//
//  MessageRepository.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 18/05/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class MessageRepository {
    
    private var listener: ListenerRegistration?
    private var contacts: [Contact] = []
    private var lastDocument: DocumentSnapshot?
    private var hasLoadedInitial = false
    
    func getContacts(completion: @escaping (String?, [Contact]) -> Void) {
        
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        
        // PRIMEIRA CARGA
        if !hasLoadedInitial {
            hasLoadedInitial = true
            
            Firestore.firestore()
                .collection("last-messages")
                .document(fromId)
                .collection("contacts")
                .order(by: "timestamp", descending: true)
                .limit(to: 20)
                .getDocuments{ snapshot, error in
                    
                    if let error = error {
                        completion(error.localizedDescription, [])
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {return}
                    
                    self.contacts = documents.map{ doc in
                        let data = doc.data()
                        return Contact(
                            uuid: doc.documentID,
                            name: data["name"] as? String ?? "",
                            profileUrl: data["profileUrl"] as? String ?? "",
                            lastMessage: data["lastMessage"] as? String,
                            timestamp: data["timestamp"] as? UInt
                        )
                    }
                    
                    self.lastDocument = documents.last
                    
                    completion(nil, self.contacts)
                    
                    // Inicia listener para atualizações
                    self.startListener(fromId: fromId, completion: completion)
                }
            return
        }
        
        // PAGINAÇÃO: carrega mais contatos
        guard let lastDocument = lastDocument else { return }
        
        Firestore
            .firestore()
            .collection("last-messages")
            .document(fromId)
            .collection("contacts")  // Busca todos os usuarios que trocaram mensagem com o usuario logado
            .order(by: "timestamp", descending: true)
            .start(afterDocument: lastDocument)
            .limit(to: 20)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(error.localizedDescription, [])
                    return
                }
                
                guard let documents = snapshot?.documents else {return}
                
                let newContacts = documents.map{ doc in
                    let data = doc.data()
                    return Contact(
                        uuid: doc.documentID,
                        name: data["name"] as? String ?? "",
                        profileUrl: data["profileUrl"] as? String ?? "",
                        lastMessage: data["lastMessage"] as? String,
                        timestamp: data["timestamp"] as? UInt
                    )
                }
                
                self.contacts.append(contentsOf: newContacts)
                self.lastDocument = documents.last
                
                completion(nil, newContacts)
            }
    }
    
    private func startListener(fromId: String, completion: @escaping (String?, [Contact]) -> Void) {
        
        guard listener == nil else { return }
        
        // Pega o timestamp da mensagem mais recente que você já tem
        let lastTimestamp = self.contacts.first?.timestamp ?? 0
        
        listener = Firestore
            .firestore()
            .collection("last-messages")
            .document(fromId)
            .collection("contacts")
            .order(by: "timestamp", descending: true)
            .whereField("timestamp", isGreaterThan: lastTimestamp)  // ← só mensagens NOVAS
            .addSnapshotListener { snapshot, error in
                
                guard let change = snapshot?.documentChanges.first else { return }
                
                if change.type == .added || change.type == .modified {
                    let doc = change.document
                    let data = doc.data()
                    
                    let contact = Contact(
                        uuid: doc.documentID,
                        name: data["name"] as? String ?? "",
                        profileUrl: data["profileUrl"] as? String ?? "",
                        lastMessage: data["lastMessage"] as? String,
                        timestamp: data["timestamp"] as? UInt
                    )
                    
                    // Remove se já existe
                    self.contacts.removeAll { $0.uuid == contact.uuid }
                    // Adiciona no topo (conversa mais recente)
                    self.contacts.insert(contact, at: 0)
                    
                    completion(nil, self.contacts)
                }
            }
    }

    
    func logout() {
        try? Auth.auth().signOut()
    }
    
    func removeListener() {
        listener?.remove()
        listener = nil
        hasLoadedInitial = false
        contacts.removeAll()
    }
}
