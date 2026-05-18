//
//  MessagesView.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 15/05/26.
//

import SwiftUI

struct MessageView: View {
    @StateObject var viewModel = MessageViewModel()
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                }
                List(viewModel.contacts, id: \.self){ contact in
                    NavigationLink{
                        ChatView(contact: contact)
                    } label: {
                        ContactMessageRow(contact: contact)
                    }
                }
            }
            .onAppear() {
                viewModel.getContacts()
            }
            .navigationTitle("Mensagens")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    NavigationLink("Contatos", destination: ContactView())

                    Button("Logout") {
                        viewModel.logout()
                    }
                }
            }
        }
    }
}

struct ContactMessageRow : View {
    var contact: Contact
    var body: some View {
        HStack {
            AsyncImage(url : URL(string: contact.profileUrl)){ image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 50, height: 50)
            
            VStack(alignment: .leading) {
                Text(contact.name)
                if let message = contact.lastMessage {
                    Text(message)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
    }
}

#Preview {
    MessageView()
}
