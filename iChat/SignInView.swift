//
//  ContentView.swift
//  iChat
//
//  Created by Tiago Aguiar on 07/10/21.
//

import SwiftUI

struct SignInView: View {
    
    @StateObject var viewModel = SignInViewModel()

    var body: some View {
        NavigationView{
            VStack{
                Image("chat_logo")
                    .resizable()
                    .scaledToFit()
                    .padding()
                
                TextField("Entre com seu e-mail", text: $viewModel.email)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(24.0)
                    .overlay(RoundedRectangle(cornerRadius: 24.0)
                        .strokeBorder(Color(UIColor.separator),
                                      style: StrokeStyle(lineWidth:1.0))
                    )
                    .padding(.bottom, 20)
                
                SecureField("Entre com sua senha", text: $viewModel.password)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(24.0)
                    .overlay(RoundedRectangle(cornerRadius: 24.0)
                        .strokeBorder(Color(UIColor.separator),
                                      style: StrokeStyle(lineWidth:1.0))
                    )
                    .padding(.bottom, 30)
                
                if(viewModel.isLoading){
                    ProgressView()
                        .padding()
                }
                
                Button(
                    action: {viewModel.signIn()},
                    label: {Text("Entrar")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("GreenColor"))
                            .foregroundColor(Color.white)
                            .cornerRadius(24.0)
                    }
                )
                .alert(isPresented: $viewModel.formInvalid){
                    Alert(title: Text(viewModel.alertText))
                }
                
                Divider()
                    .padding()
                
                NavigationLink(
                    destination: SignUpView(),
                    label: {
                        Text("Não tem uma conta? Clique aqui.")
                            .foregroundColor(Color.black)
                    }
                )
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal,32)
            .background(Color.init(red: 240/255, green:231/255, blue:210/255))
            .navigationTitle("Login")
            .navigationBarHidden(true)
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
