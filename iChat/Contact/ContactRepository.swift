//
//  ContactRepository.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 18/05/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class ContactRepository {
    
    func getContacts(completion: @escaping (String?, [Contact]) -> Void) {
        var contacts: [Contact] = []
        Firestore
            .firestore()
            .collection("users")
            .getDocuments(){
                querySnapshot, error in
                if let error = error {
                    completion(error.localizedDescription, [])
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
                        contacts.append(contact)
                        continue
                    }
                    let contact = Contact(
                        uuid: document.documentID,
                        name: data["name"] as! String,
                        profileUrl: data["profileUrl"] as! String
                    )
                    contacts.append(contact)
                    print("ID \(document.documentID) \(document.data())")
                }
                completion(nil, contacts)
            }
    }
}
