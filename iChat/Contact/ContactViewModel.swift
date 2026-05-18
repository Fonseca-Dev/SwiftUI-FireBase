//
//  ContactsViewModel.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 16/05/26.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class ContactViewModel: ObservableObject {
    
    @Published var contacts: [Contact] = []
    @Published var isLoading: Bool = false
    private let repo: ContactRepository
    
    init(repo: ContactRepository){
        self.repo = repo
    }
    
    private var isLoaded: Bool = false
    
    func getContacts() {
        if isLoaded { return }
        isLoading = true
        
        repo.getContacts { error, contacts in
            if let error = error {
                print("Erro ao buscar contatos:", error.localizedCapitalized)
                self.isLoading = false
                self.isLoaded = true
                return
            }
            
            self.isLoading = false
            self.isLoaded = true
            self.contacts.append(contentsOf: contacts)
        }
    }
}
