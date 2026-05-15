//
//  SignInViewModel.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 15/05/26.
//

import Foundation

class SignInViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    func signIn() {
        print("Signing in with email: \(email) and password: \(password)")
    }
}
