//
//  ChatViewModel.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 16/05/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class ChatViewModel: ObservableObject {
    
    @Published var messages: [Message] =  [
        /*Message(uuid: "1", text: "Mesnagem 1 sauygsuaadnsbuoidfsabfsoaifsgvaifbansofuvafsbaoibfsaboufbosoabfsabiuvfskaf silbdusfayiskvfdabsobiuoa d", isMe: true),
        Message(uuid: "2", text: "Mesnagem 2", isMe: false),
        Message(uuid: "3", text: "Mesnagem 3", isMe: true),
        Message(uuid: "4", text: "Mesnagem 4 siudahdiaisdaslfdasvivf;blsabfsablcdifvald.bfauidbgsaibfd iakdbifdsvgbfidubofdbobgbsfbgoblfbsonlsbof s blgsbs", isMe: false),
        Message(uuid: "5", text: "Mesnagem 5", isMe: true),
        Message(uuid: "6", text: "Mesnagem 6", isMe: false),
        Message(uuid: "7", text: "Mesnagem 7 \n siahigidsagdsiads", isMe: true),
        Message(uuid: "8", text: "Mesnagem 8", isMe: false),
        Message(uuid: "9", text: "Mesnagem 9", isMe: true),
        Message(uuid: "10", text: "Mesnagem 10 \n siahigidsagdsiads", isMe: false),*/

    ]
    
    @Published var newMessage: String = ""
    
    var myName = ""
    var myPhoto = ""
    var inserting: Bool = false
    var newCount: Int = 0
    let limit = 10
    
    private let repo: ChatRepository
    
    init(repo: ChatRepository){
        self.repo = repo
    }
    
    
    func onAppear(toContact: Contact){
        
        repo.onAppear(toContact: toContact) { messages, name, photo in
                self.messages = messages
                self.myName = name
                self.myPhoto = photo
            }
    }
    
    func sendMessage(toContact: Contact) {
        
        let message = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Se a mensagem não estiver vazia, continue.
        guard !message.isEmpty else { return }
        
        newMessage = ""  // limpa o campo
        
        repo.sendMessage(toContact: toContact, message: message) { error in
            if let error = error {
                print("Erro ao enviar mensagem:", error.localizedDescription)
            }
        }
    }
    
    func onDesapear(){
        repo.removeListener()
    }
}
