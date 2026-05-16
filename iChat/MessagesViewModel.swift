//
//  MessagesViewModel.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 15/05/26.
//

import Foundation
import FirebaseAuth

class MessagesViewModel:ObservableObject {
    
    func logout() {
        try? Auth.auth().signOut()
    }
    
}
