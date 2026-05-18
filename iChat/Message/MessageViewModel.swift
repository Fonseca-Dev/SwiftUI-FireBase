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
    
    private let repo: MessageRepository
    
    init(repo: MessageRepository){
        self.repo = repo
    }

    
    func getContacts() {
        isLoading = true
        
        repo.getContacts { error, contacts in
            if let error = error {
                print("Erro ao buscar contatos:", error.localizedCapitalized)
                self.isLoading = false
                return
            }
            self.contacts = contacts
        }
        self.isLoading = false
    }
    
    func logout() {
        repo.logout()
    }
    
}
