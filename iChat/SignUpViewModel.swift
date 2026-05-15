//
//  SignUpViewModel.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 15/05/26.
//

import Foundation
import FirebaseAuth

class SignUpViewModel: ObservableObject {
    
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var formInvalid = false
    @Published var alertText: String = ""
    @Published var isLoading = false
    
    
    
    func signUp() {
        isLoading = true
        print("nome: \(name), email: \(email), senha: \(password)")
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard let user = authResult?.user, error == nil else {
                self.formInvalid = true
                self.alertText = error!.localizedDescription
                print(error)
                self.isLoading = false
                return
            }
            self.isLoading = false
            print("Usuario criado: \(user.uid)")
        }
    }
}
