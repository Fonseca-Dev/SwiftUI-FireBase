//
//  MessagesViewModel.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 15/05/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class MessagesViewModel:ObservableObject {
    
    @Published var isLoading:Bool = false
    @Published var contacts: [Contact] = []
    private var isLoaded: Bool = false

    
    func getContacts() {
        if isLoaded { return }
        isLoading = true
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        
        Firestore
            .firestore()
            .collection("last-messages")
            .document(fromId)
            .collection("contacts")  // Busca todos os usuarios que trocaram mensagem com o usuario logado
            .addSnapshotListener{ (querySnapshot, error) in
                if let changes = querySnapshot?.documentChanges {
                    self.contacts.removeAll()
                    for doc in changes {
                        if doc.type == .added {
                            let document = doc.document
                            print(document.data())
                            
                            self.contacts.append(
                                Contact(
                                    uuid: document.documentID,
                                    name: document.data()["name"] as? String ?? "",
                                    profileUrl: document.data()["profileUrl"] as? String ?? "",
                                    lastMessage: document.data()["lastMessage"] as? String,
                                    timestamp: document.data()["timestamp"] as? UInt
                                )
                            )
                        }
                    }
                    self.isLoaded = true
                    self.isLoading = false
                }
            }
        
    }
    
    
    func logout() {
        try? Auth.auth().signOut()
    }
    
}
