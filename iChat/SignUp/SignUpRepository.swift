//
//  SignUpRepository.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 17/05/26.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import UIKit

class SignUpRepository {
    func signUp(withEmail: String, password: String, image:UIImage?, userName:String, completion: @escaping (String?) -> Void) {
        Auth.auth().createUser(withEmail: withEmail, password: password) { authResult, error in
            guard let user = authResult?.user, error == nil else {
                completion(error!.localizedDescription)
                print(error!)
                return
            }
            print("Usuario criado: \(user.uid)")
            self.uploadPhoto(image: image, userName: userName){ error in
                if let error = error {
                    completion(error)
                    return
                }
                completion(nil)
            }
        }
        
    }
    
    private func uploadPhoto(image: UIImage?, userName:String, completion: @escaping (String?) -> Void) {
        let filename = UUID().uuidString
        
        // Conversao de um objeto img para um objeto binário
        guard let data = image!.jpegData(compressionQuality: 0.2) else { return }
        
        let newMetadata = StorageMetadata()
        newMetadata.contentType = "image/jpg"
        
        let ref = Storage.storage().reference(withPath: "/images/\(filename).jpg")
        
        
        ref.putData(data, metadata: newMetadata){
            metadata, error in
            if let error = error {
                        completion(error.localizedDescription)
                        print("Erro no upload:", error.localizedDescription)
                        return
                    }
            
            ref.downloadURL { url, error in
                if let error = error {
                    completion(error.localizedDescription)
                    print("Erro ao pegar URL:", error.localizedDescription)
                    return
                }
                
                guard let url = url else {
                    return
                }

                print("Upload sucesso:", url.absoluteString)
                self.createUser(imageUrl: url, name: userName, completion: completion)
            }
        }
    }
    
    private func createUser(imageUrl: URL, name:String, completion: @escaping (String?) -> Void) {
        let uid = Auth.auth().currentUser!.uid
        
        Firestore.firestore().collection("users")
            .document(uid)
            .setData([
                "name": name,
                "uuid": uid,
                "profileUrl": imageUrl.absoluteString
            ]) { error in
                if let error = error {
                    print("Erro ao criar usuário:", error.localizedDescription)
                    completion(error.localizedDescription)
                    return
                }
                print("Usuário criado com sucesso!")
            }
    }
}
