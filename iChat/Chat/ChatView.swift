//
//  ChatView.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 16/05/26.
//

import SwiftUI

struct ChatView: View {
    
    let contact: Contact
    
    @StateObject private var viewModel = ChatViewModel(repo: ChatRepository())
    @State private var textSize: CGSize = .zero
    
    @Namespace private var bottomID // Serve para alocar um identificador unico para qualquer componente de View
    
    var body: some View {
        VStack {
            ScrollViewReader { value in
                ScrollView(showsIndicators: false) {
                    Color.clear
                        .id(bottomID)
                    LazyVStack {
                        ForEach(viewModel.messages, id: \.self){ message in
                            MessageRow(message: message)
                                .scaleEffect(x: 1.0, y: -1.0, anchor: .center)
                                .onAppear{
                                    // Só dispara a request quando estiver no ultimo da lista e a quantidade de mensagens for menos do que o limite
                                    // Para nao ficar fazendo request sem ter atingido o limite
                                    if message == viewModel.messages.last && viewModel.messages.count >= viewModel.limit {
                                        viewModel.onAppear(toContact: contact)
                                    }
                                }
                        }
                        .onChange(of: viewModel.newCount) { newValue in // O newCount só mudará quando houver um inster
                            print("Count is \(newValue)")
                            print("Total is \(viewModel.messages.count)")
                            print("Limit is \(viewModel.limit)")
                            // Que sera o momento que ocorrera o scroll
                            if newValue > viewModel.messages.count {
                                withAnimation {
                                    value.scrollTo(bottomID)
                                }
                            }
                        }
                    }
                }
                .simultaneousGesture(DragGesture().onChanged({ _ in
                    UIApplication.shared.endEditting()
                }))
                .rotationEffect(Angle(degrees: 180.0))
                .scaleEffect(x: -1.0, y: 1.0, anchor: .center)
                
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
        .onDisappear() {
            viewModel.onDesapear()
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
        VStack(alignment: .leading){
            Text(message.text)
                .padding(.vertical, 5)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10.0)
                        .fill(!message.isMe ? Color(white: 0.95) : Color("GreenLightColor"))
                )
                .frame(maxWidth: 260, alignment: message.isMe ? .trailing : .leading)
            // trailing (alinhamento a direita), leading (alinhamento a esquerda)
                
        }
        .padding(.horizontal, 2)
        .frame(maxWidth: .infinity, alignment: message.isMe ? .trailing : .leading)
        
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
