//
//  ContactsView.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 16/05/26.
//

import Foundation
import SwiftUI

struct ContactsView: View {
    
    @StateObject var viewModel = ContactsViewModel()
    var body: some View {
        
        VStack {
            List(viewModel.contacts, id: \.self) { contact in
                ContactRow(contact: contact)
            }
        }.onAppear {
            viewModel.getContacts()
        }
    }
}

struct ContactRow : View {
    
    var contact: Contact
    
    var body: some View {
        HStack {
            AsyncImage(url : URL(string: contact.profileUrl)){ image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 50, height: 50)
            Text(contact.name)
        }
    }
}

#Preview {
    ContactsView()
}
