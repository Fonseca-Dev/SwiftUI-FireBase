//
//  SignUpView.swift
//  iChat
//
//  Created by Kaue Rocha da Fonseca on 15/05/26.
//

import SwiftUI
import UIKit

struct SignUpView: View {
    
    @StateObject var viewModel = SignUpViewModel(repo: SignUpRepository())
    @State var isShowPhotoLibrary: Bool = false

    var body: some View {
        VStack{
            Button {
                isShowPhotoLibrary = true
            } label: {
                if(viewModel.image != nil ){
                    Image(uiImage: viewModel.image!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 130, height: 130)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color("GreenColor"),
                                                lineWidth: 4))
                        .shadow(radius: 7)
                }else {
                    Text("Foto")
                        .frame(width: 130, height: 130)
                        .background(Color("GreenColor"))
                        .foregroundColor(Color.white)
                        .cornerRadius(100.0)
                }
            }
            .padding(.bottom,32)
            .sheet(isPresented: $isShowPhotoLibrary) {
                ImagePicker(selectedImage: $viewModel.image)
            }

            
            TextField("Entre com seu nome", text: $viewModel.name)
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
                action: {viewModel.signUp()},
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
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal,32)
        .background(Color.init(red: 240/255, green:231/255, blue:210/255))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
