//
//  MessagesViewModel.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 15/05/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class MessageViewModel:ObservableObject {
    
    @Published var isLoading:Bool = false
    @Published var contacts: [Contact] = []
    private var listener: ListenerRegistration?


    
    func getContacts() {
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        
        if listener != nil { return }
        
        isLoading = true

        
        listener = Firestore
            .firestore()
            .collection("last-messages")
            .document(fromId)
            .collection("contacts")  // Busca todos os usuarios que trocaram mensagem com o usuario logado
            .order(by: "timestamp", descending: true)
            .addSnapshotListener{ (querySnapshot, error) in
                
                if let error =
                    error {
                    print("Erro ao buscar mensagens:", error.localizedDescription)
                    self.isLoading = false
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                                    self.isLoading = false
                                    return
                                }
                
                self.contacts = documents.map { document in
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
                
                self.isLoading = false
            }
    }
    
    
    func logout() {
        try? Auth.auth().signOut()
    }
    
}
