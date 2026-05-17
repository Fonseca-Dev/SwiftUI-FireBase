//
//  iChatApp.swift
//  iChat
//
//  Created by Tiago Aguiar on 07/10/21.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct iChatApp: App {
        
    init() {
            FirebaseApp.configure()
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

extension UIApplication {
    func endEditting() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
