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
