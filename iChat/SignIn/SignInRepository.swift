//
//  SignInRepository.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 17/05/26.
//

import Foundation
import FirebaseAuth

class SignInRepository {
    func signIn(withEmail: String, password: String, completion: @escaping (String?) -> Void) { // escaping pq é uma funcao que vai demorar no futuro
        Auth.auth().signIn(withEmail: withEmail, password: password) { authResult, error in
            guard let user = authResult?.user, error == nil else {
                completion(error!.localizedDescription)
                print(error ?? "Erro desconhecido")
                return
            }
            print("Usuario Logado: \(user.uid)")
            completion(nil)
        }
    }
}
