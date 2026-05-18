//
//  SignInViewModel.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 15/05/26.
//

import Foundation
import FirebaseAuth

class SignInViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var formInvalid: Bool = false
    @Published var alertText: String = ""
    
    private let repo: SignInRepository
    
    init(repo : SignInRepository){
        self.repo = repo
    }
    
    
    func signIn() {
        self.isLoading = true
        repo.signIn(withEmail: email, password: password) { error in
            if let error = error {
                self.formInvalid = true
                self.alertText = error.localizedCapitalized
                self.isLoading = false
                print(error)
            }
            self.isLoading = false
        }
    }
}
