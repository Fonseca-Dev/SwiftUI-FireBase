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

class SignUpViewModel: ObservableObject {
    
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var formInvalid = false
    @Published var alertText: String = ""
    @Published var isLoading = false
    @Published var image: UIImage? = nil
    
    
    
    func signUp() {
        print("nome: \(name), email: \(email), senha: \(password)")
        
        // Para cadastrar é necessario selecionar uma foto
        if(image?.size.width ?? 0 <= 0){
            formInvalid = true
            alertText = "Por favor, insira uma imagem de perfil"
            return
        }
        
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard let user = authResult?.user, error == nil else {
                self.formInvalid = true
                self.alertText = error!.localizedDescription
                print(error ?? "Erro ao criar usuario")
                self.isLoading = false
                return
            }
            self.isLoading = false
            print("Usuario criado: \(user.uid)")
            
            self.uploadPhoto()
        }
    }
    
    private func uploadPhoto() {
        let filename = UUID().uuidString
        
        // Conversao de um objeto img para um objeto binário
        guard let data = image?.jpegData(compressionQuality: 0.2) else { return }
        
        let newMetadata = StorageMetadata()
        newMetadata.contentType = "image/jpg"
        
        let ref = Storage.storage().reference(withPath: "/images/\(filename).jpg")
        
        
        ref.putData(data, metadata: newMetadata){
            metadata, error in
            if let error = error {
                        print("Erro no upload:", error.localizedDescription)
                        self.isLoading = false
                        return
                    }
            ref.downloadURL { url, error in
                if let error = error {
                                print("Erro ao pegar URL:", error.localizedDescription)
                                self.isLoading = false
                                return
                            }
                            
                            print("Upload sucesso:", url?.absoluteString ?? "")
                            self.isLoading = false
            }
            
        }
    }
}
