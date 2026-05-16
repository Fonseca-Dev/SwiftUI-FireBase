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
    
    func onAppear(toId: String){
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        
        Firestore
            .firestore()
            .collection("chats")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { querySnapshot, error in // Esse daqui é o responsavel por ficar ouvindo as alteracoes no banco de dados
                if let error = error {
                    print("ERROR: fetching documents \(error)")
                    return
                }
                
                if let changes = querySnapshot?.documentChanges {
                    for documentChange in changes {
                        let document = documentChange.document
                        
                        print ("Document is: \(document.documentID) \(document.data())")
                        
                        let message = Message(
                            uuid: document.documentID,
                            text: document.data()["message"] as! String,
                            isMe: fromId == (document.data()["fromId"] as! String),
                            )
                        self.messages.append(message)
                    }
                }
            }
    }
    
    func sendMessage(toId : String){
        guard let fromId = Auth.auth().currentUser?.uid else { return } // Busca o id do usuario que esta enviando a mensagem
        let timestamp = Date().timeIntervalSince1970 // Busca o horario em segundos do momento em que esta sendo enviado a mensagem
        
        // Aqui eu crio uma colecao para quem ta enviando a mensagem
        Firestore
            .firestore()
            .collection("chats") // Criacao da colecao chats(Conversas)
            .document(fromId) // Nessa colecao vai ter um remetente
            .collection(toId) // Criacao da colecao para quem as mensagens estao sendo enviadas
            .addDocument(data: [
                "message": newMessage,
                "fromId": fromId,
                "toId": toId,
                "timestamp": UInt(timestamp) // Unidade de inteiro que não aceita numeros negativos
            ]) { error in
                if error != nil {
                    print("Error adding document: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
            }
        
        // Aqui eu crio uma colecao para quem ta recebendo a mensagem
        Firestore
            .firestore()
            .collection("chats") // Criacao da colecao chats(Conversas)
            .document(toId) // Nessa colecao vai ter um destinatario
            .collection(fromId) // Criacao da colecao para quem as mensagens estao sendo recebidas
            .addDocument(data: [
                "message": newMessage,
                "fromId": fromId,
                "toId": toId,
                "timestamp": UInt(timestamp) // Unidade de inteiro que não aceita numeros negativos
            ]) { error in
                if error != nil {
                    print("Error adding document: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
            }
        
            
    }
}
