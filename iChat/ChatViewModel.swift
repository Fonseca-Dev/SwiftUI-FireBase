//
//  ChatViewModel.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 16/05/26.
//

import Foundation

class ChatViewModel: ObservableObject {
    
    @Published var messages: [Message] = [
        Message(uuid: UUID().uuidString, text: "Mensagem 1", isMe: false),
        Message(uuid: UUID().uuidString, text: "Mensagem 2", isMe: false),
        Message(uuid: UUID().uuidString, text: "Mensagem 3", isMe: false),
        Message(uuid: UUID().uuidString, text: "Mensagem 4", isMe: false),
        Message(uuid: UUID().uuidString, text: "Mensagem 5", isMe: false),
        Message(uuid: UUID().uuidString, text: "Mensagem 6", isMe: false),
        Message(uuid: UUID().uuidString, text: "Mensagem 7", isMe: false),
        Message(uuid: UUID().uuidString, text: "Mensagem 8", isMe: false),

    ]
    
    @Published var newMessage: String = ""
    
    
}
