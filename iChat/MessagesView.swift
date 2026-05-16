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
        Button{
            viewModel.logout()
        } label: {
            Text("Logout")
        }
    }
}

#Preview {
    MessagesView()
}
