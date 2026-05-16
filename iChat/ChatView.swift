//
//  ChatView.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 16/05/26.
//

import SwiftUI

struct ChatView: View {
    
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
                
                Button(action: {}) {
                    Image(systemName: "paperplane")
                        .padding()
                        .background(Color("GreenColor"))
                        .foregroundColor(Color.white)
                        .cornerRadius(24.0)
                }
                .disabled(viewModel.newMessage.isEmpty)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
        }
        .navigationTitle(contactName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MessageRow : View {
    
    let message: Message
    
    var body: some View {
        Text(message.text)
            .background(Color(white: 0.95))
            .frame(maxWidth: .infinity, alignment: message.isMe ? .leading : .trailing)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.leading, message.isMe ? 0 : 150)
            .padding(.trailing, message.isMe ? 150 : 0)
            .padding(.vertical, 5)
    }
}

#Preview {
    ChatView(contactName: "Kaue")
}
