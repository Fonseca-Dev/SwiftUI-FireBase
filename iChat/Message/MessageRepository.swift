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

    func getContacts(completion: @escaping (String?, [Contact]) -> Void) {
        var contacts: [Contact] = []
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        
        if listener != nil { return }
        
        listener = Firestore
            .firestore()
            .collection("last-messages")
            .document(fromId)
            .collection("contacts")  // Busca todos os usuarios que trocaram mensagem com o usuario logado
            .order(by: "timestamp", descending: true)
            .addSnapshotListener{ (querySnapshot, error) in
                if let error =
                    error {
                    completion(error.localizedDescription, [])
                    print("Erro ao buscar mensagens:", error.localizedDescription)
                    return
                }
                
                guard let documents = querySnapshot?.documents else {return}
                
                contacts = documents.map { document in
                                    let data = document.data()
                                    print(data)
                                    return Contact(
                                            uuid: document.documentID,
                                            name: data["name"] as? String ?? "",
                                            profileUrl: data["profileUrl"] as? String ?? "",
                                            lastMessage: data["lastMessage"] as? String,
                                            timestamp: data["timestamp"] as? UInt
                                        )
                                    }
                completion(nil, contacts)
            }
    }
    
    func logout() {
        try? Auth.auth().signOut()
    }
    
    func removeListener() {
        listener?.remove()
        listener = nil
    }
}
