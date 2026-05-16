//
//  ContentView.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 15/05/26.
//

import Foundation
import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    
    
    
    var body: some View {
        if viewModel.isLoggedIn {
            MessagesView()
        } else {
            SignInView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    static var previews: some View {
        ContentView()
    }
}
