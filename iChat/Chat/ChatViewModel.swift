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
    
    
    func onAppear(toContact: Contact){
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        
        // Isso serve para buscar na Colecao "users" o nome e a Url da foto do usuario
        Firestore
            .firestore()
            .collection("users")
            .document(fromId)
            .getDocument{ querySnapshot, error in
                if let error = error {
                    print("ERROR: fetching documents \(error)")
                    return
                }
                
                if let data = querySnapshot?.data(){
                    self.myName = data["name"] as! String
                    self.myPhoto = data["profileUrl"] as! String
                }
                
            }
        
        
        Firestore
            .firestore()
            .collection("chats")
            .document(fromId)
            .collection(toContact.uuid)
            .order(by: "timestamp", descending: true) // Ordenacao do mais novo para o mais antigo -> Mais novo = timestamp maior, Mais velho = timestamp menor
            .start(at: [self.messages.last?.timestamp ?? 9999999999999]) // Para comecar na proxima interacao
            .limit(to: limit) // Quantos elementos ele vai fazer nessa busca
            .addSnapshotListener { querySnapshot, error in // Esse daqui é o responsavel por ficar ouvindo as alteracoes no banco de dados
                if let error = error {
                    print("ERROR: fetching documents \(error)")
                    return
                }
                
                if let changes = querySnapshot?.documentChanges {
                    for documentChange in changes {
                        if documentChange.type == .added {
                            let document = documentChange.document
                            
                            print ("Document is: \(document.documentID) \(document.data())")
                            
                            let message = Message(
                                uuid: document.documentID,
                                text: document.data()["message"] as! String,
                                isMe: fromId == (document.data()["fromId"] as! String),
                                timestamp: document.data()["timestamp"] as! UInt
                            )
                            if self.inserting{
                                self.messages.insert(message, at: 0)
                            } else {
                                if(document.documentID != self.messages.last?.uuid){
                                    self.messages.append(message)
                                }
                            }
                        }
                    }
                    print("-------")
                    self.inserting = false
                }
                self.newCount = self.messages.count
            }
    }
    
    func sendMessage(toContact : Contact){
        let newMessage = self.newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        inserting = true
        newCount = newCount + 1
        self.newMessage = ""
        guard let fromId = Auth.auth().currentUser?.uid else { return } // Busca o id do usuario que esta enviando a mensagem
        let timestamp = Date().timeIntervalSince1970 // Busca o horario em segundos do momento em que esta sendo enviado a mensagem
        
        // Aqui eu crio uma colecao para quem ta enviando a mensagem
        Firestore
            .firestore()
            .collection("chats") // Criacao da colecao chats(Conversas)
            .document(fromId) // Que tem o remetente
            .collection(toContact.uuid) // Criacao da colecao com id do destinatario para ter um unico chat vinculado aos dois usuarios
            .addDocument(data: [
                "message": newMessage,
                "fromId": fromId,
                "toId": toContact.uuid,
                "timestamp": UInt(timestamp) // Unidade de inteiro que não aceita numeros negativos
            ]) { error in
                if error != nil {
                    print("Error adding document: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                // Aqui é gerado a coleçao de last-messages
                Firestore
                    .firestore()
                    .collection("last-messages")
                    .document(fromId) // Que tem o remetente
                    .collection("contacts") // Cria um colecao de contatos com quem ja trocou mensagem
                    .document(toContact.uuid) // Vincula o destinatario a essa colecao
                    .setData([
                        "uuid": toContact.uuid,
                        "name": toContact.name,
                        "profileUrl": toContact.profileUrl,
                        "timestamp": UInt(timestamp),
                        "lastMessage": newMessage
                    ])
            }
        
        // Aqui eu crio uma colecao para quem ta recebendo a mensagem
        Firestore
            .firestore()
            .collection("chats") // Criacao da colecao chats(Conversas)
            .document(toContact.uuid) // Que tem o destinatario
            .collection(fromId) // Criacao da colecao com id do remetente para ter um unico chat vinculado aos dois usuarios
            .addDocument(data: [
                "message": newMessage,
                "fromId": fromId,
                "toId": toContact.uuid,
                "timestamp": UInt(timestamp) // Unidade de inteiro que não aceita numeros negativos
            ]) { error in
                if error != nil {
                    print("Error adding document: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                // Aqui é gerado a coleçao de last-messages
                Firestore
                    .firestore()
                    .collection("last-messages")
                    .document(toContact.uuid) // Que tem o destinatario
                    .collection("contacts") // Cria um colecao de contatos com quem ja trocou mensagem
                    .document(fromId) // Vincula o remetente a essa colecao
                    .setData([
                        "uuid": fromId,
                        "name": self.myName,
                        "profileUrl": self.myPhoto,
                        "timestamp": UInt(timestamp),
                        "lastMessage": newMessage
                    ])
                
            }        
    }
}
