//
//  ContactsViewModel.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 16/05/26.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class ContactsViewModel: ObservableObject {
    
    @Published var contacts: [Contact] = []
    @Published var isLoading: Bool = false
    
    private var isLoaded: Bool = false
    
    func getContacts() {
        if isLoaded { return }
        isLoading = true
        Firestore
            .firestore()
            .collection("users")
            .getDocuments(){
                querySnapshot, error in
                if let error = error {
                    self.isLoaded = true
                    self.isLoading = false
                    print("Error ao buscar contatos: \(error)")
                    return
                }
                
                for document in querySnapshot!.documents {
                    guard let myId = Auth.auth().currentUser?.uid else { return }
                    let data = document.data()

                    if myId == document.documentID {
                        let contact = Contact(
                            uuid: document.documentID,
                            name: "Eu",
                            profileUrl: data["profileUrl"] as! String
                        )
                        self.contacts.append(contact)
                        continue
                    }
                    let contact = Contact(
                        uuid: document.documentID,
                        name: data["name"] as! String,
                        profileUrl: data["profileUrl"] as! String
                    )
                    self.contacts.append(contact)
                    print("ID \(document.documentID) \(document.data())")
                }
                self.isLoaded = true
                self.isLoading = false
            }
    }
}
