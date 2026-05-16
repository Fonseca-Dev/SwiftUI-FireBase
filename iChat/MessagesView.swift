//
//  MessagesView.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 15/05/26.
//

import SwiftUI

struct MessagesView: View {
    @StateObject var viewModel = MessagesViewModel()
    var body: some View {
        NavigationStack {
            VStack {
                Text("Hello, World!")
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    NavigationLink("Contatos", destination: ContactsView())

                    Button("Logout") {
                        viewModel.logout()
                    }
                }
            }
        }
    }
}

#Preview {
    MessagesView()
}
