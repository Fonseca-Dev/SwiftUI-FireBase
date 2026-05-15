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
    
    func signIn() {
        self.isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            guard let user = authResult?.user, error == nil else {
                self.formInvalid = true
                self.alertText = error!.localizedDescription
                print(error ?? "Erro desconhecido")
                self.isLoading = false
                return
            }
            self.isLoading = false
            print("Usuario Logado: \(user.uid)")
        }
    }
}
