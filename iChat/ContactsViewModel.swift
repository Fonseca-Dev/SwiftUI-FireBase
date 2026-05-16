//
//  ContactsViewModel.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 16/05/26.
//

import SwiftUI
import FirebaseFirestore

class ContactsViewModel: ObservableObject {
    
    @Published var contacts: [Contact] = []
    
    func getContacts() {
        Firestore
            .firestore()
            .collection("users")
            .getDocuments(){
                querySnapshot, error in
                if let error = error {
                    print("Error ao buscar contatos: \(error)")
                    return
                }
                
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let contact = Contact(
                        uuid: document.documentID,
                        name: data["name"] as! String,
                        profileUrl: data["profileUrl"] as! String
                    )
                    self.contacts.append(contact)
                    print("ID \(document.documentID) \(document.data())")
                }
            }
    }
}
