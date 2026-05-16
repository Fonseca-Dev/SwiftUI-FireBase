//
//  ChatView.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 16/05/26.
//

import SwiftUI

struct ChatView: View {
    
    let toContactId: String
    let contactName: String
    
    @StateObject private var viewModel = ChatViewModel()
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                ForEach(viewModel.messages, id: \.self){ message in
                    MessageRow(message: message)
                }
            }
            
            Spacer()
            
            HStack {
                TextField("Type a message", text: $viewModel.newMessage)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(24.0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24.0)
                            .strokeBorder(Color(UIColor.separator),style: StrokeStyle(lineWidth: 1.0))
                    )
                
                Button(action: {viewModel.sendMessage(toId: toContactId)}) {
                    Image(systemName: "paperplane")
                        .padding()
                        .background(Color("GreenColor"))
                        .foregroundColor(Color.white)
                        .cornerRadius(24.0)
                }
                .disabled(viewModel.newMessage.isEmpty)
            }
        }
        .padding()
        .navigationTitle(contactName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            viewModel.onAppear(toId: toContactId)
        }
    }
}

struct MessageRow : View {
    
    let message: Message
    
    var body: some View {
            Text(message.text)
                .background(Color(white: 0.95))
                .frame(maxWidth: .infinity, alignment: message.isMe ? .trailing : .leading) // trailing (alinhamento a direita), leading (alinhamento a esquerda)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, message.isMe ? 100 : 0)
                .padding(.trailing, message.isMe ? 0 : 100)
                .padding(.vertical, 5)
        
    }
}

#Preview {
    ChatView(toContactId: "1", contactName: "Kaue")
}
