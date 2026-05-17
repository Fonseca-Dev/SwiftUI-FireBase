//
//  ChatView.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 16/05/26.
//

import SwiftUI

struct ChatView: View {
    
    let contact: Contact
    
    @StateObject private var viewModel = ChatViewModel()
    @State private var textSize: CGSize = .zero
    
    @Namespace private var bottomID // Serve para alocar um identificador unico para qualquer componente de View
    
    var body: some View {
        VStack {
            ScrollViewReader { value in
                ScrollView(showsIndicators: false) {
                    ForEach(viewModel.messages, id: \.self){ message in
                        MessageRow(message: message)
                    }
                    .onChange(of: viewModel.messages.count) { newValue in
                        withAnimation {
                            value.scrollTo(bottomID)
                        }
                    }
                    
                    Color.clear
                        .id(bottomID)
                }
                
            }
            
            
            Spacer()
            
            HStack {
                ZStack{
                    TextEditor(text: $viewModel.newMessage)
                        .scrollContentBackground(.hidden)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(24.0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24.0)
                                .strokeBorder(Color(UIColor.separator),style: StrokeStyle(lineWidth: 1.0))
                        )
                        .frame(minHeight: 50,
                               maxHeight: textSize.height > 20 ? min(textSize.height + 30, 100) : 50)
                    
                    Text(viewModel.newMessage)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .background(ViewGeometry())
                        .lineLimit(4)
                        .hidden()
                        .onPreferenceChange(ViewSizeKey.self){ size in
                            textSize = size
                        }
                }
                
                Button(action: {viewModel.sendMessage(toContact: contact)}) {
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
        .navigationTitle(contact.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            viewModel.onAppear(toContact: contact)
        }
    }
}

// Para obter a altura e largura do component
struct ViewGeometry: View {
    var body: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: ViewSizeKey.self, value: geometry.size)
        }
    }
}

struct ViewSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
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
    ChatView(
        contact: Contact(
            uuid: "1",
            name: "User 1",
            profileUrl: "String",
        )
    )
}
