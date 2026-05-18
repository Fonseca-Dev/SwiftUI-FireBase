//
//  SignUpViewModel.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 15/05/26.
//

import Foundation
import FirebaseAuth
import UIKit
import FirebaseStorage
import FirebaseFirestore

class SignUpViewModel: ObservableObject {
    
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var formInvalid = false
    @Published var alertText: String = ""
    @Published var isLoading = false
    @Published var image: UIImage? = nil
    
    private let repo: SignUpRepository
    
    init(repo: SignUpRepository){
        self.repo = SignUpRepository()
    }
    
    func signUp() {
        print("nome: \(name), email: \(email), senha: \(password)")
        
        // Para cadastrar é necessario selecionar uma foto
        if(image?.size.width ?? 0 <= 0){
            formInvalid = true
            alertText = "Por favor, insira uma imagem de perfil"
            return
        }
        
        isLoading = true
        
        repo.signUp(withEmail: email, password: password, image: image, userName: name) { error in
            if let error = error {
                print("Erro ao cadastrar: \(error.localizedCapitalized)")
                self.formInvalid = true
                self.alertText = error.localizedCapitalized
            }
            self.isLoading = false
        }
    }
}
