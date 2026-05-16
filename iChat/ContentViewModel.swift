//
//  ContentViewModel.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 15/05/26.
//

import Foundation
import FirebaseAuth

class ContentViewModel: ObservableObject {
    
    @Published var isLoggedIn = Auth.auth().currentUser != nil
    
}
