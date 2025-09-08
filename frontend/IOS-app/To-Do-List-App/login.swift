//
//  login.swift
//  To-Do-List-App
//
//  Created by Nsamba Isaac on 23/05/2024.
//

import SwiftUI
import IQKeyboardManagerSwift

struct login: View {
    @EnvironmentObject var authManager:AuthManager
    
    var body: some View {
        
        if authManager.isLoggedIn{
            Dashboard(viewModel: TaskViewModel())
        }else{
            LoginView()
        }
        
    }
    
    

    


struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var alertMessage = ""
    @State private var showALert = false
    @State private var navigateToLogin = false
    @State private var isloading = false
    @EnvironmentObject var authManager:AuthManager
    
    var body: some View {
        NavigationView{
            
            ZStack{
                Color(red:244/255, green: 194/255,blue: 127/255).ignoresSafeArea()
                VStack{
                    
                    VStack(spacing:15){
                        Image("Done").resizable().aspectRatio(contentMode: .fit)
                        Text("Welcome back to")
                        Text("OUR REMINDER").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    }.padding()
                    
                    if isloading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(2)
                            .padding()
                    }
                    
                    Form{
                        Section(){
                            TextField("Enter your email",text: $username).background(Color.white.opacity(0.8)).autocapitalization(.none)
                        }
                        Section{
                            SecureField("Enter Password",text: $password).autocapitalization(.none)
                        }
                        
                    }.background(Color.clear).scrollContentBackground(.hidden)
                        .cornerRadius(10)
                        .padding()
                    
                    VStack(spacing:5){
                        
                        Button(action:{},
                               label: {
                            Text("Forgot Password")
                        }
                        )
                        
                        Button(action: {
                            loginUser()
                        }) {
                            //                            Dashboard().navigationBarBackButtonHidden(true))
                            Text("Sign In").foregroundColor(.white)
                        }
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: 50).background(LinearGradient(gradient: Gradient(colors: [
                            Color(red:244/255,green:194/255,blue:127/255),
                            Color(red:216/255,green:96/255,blue:91/255)
                        ]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)).cornerRadius(25).shadow(radius: 1.1).padding()
                        
                        NavigationLink(destination: register().navigationBarBackButtonHidden(true)){ Text("Don’t have an account ? Sign Up").foregroundColor(.white)}
                        
                    }
                    
                }.background(Color.clear)
            }
            
        }.alert(isPresented: $showALert){
            Alert(title: Text(alertMessage))
        }.navigationDestination(isPresented: $navigateToLogin, destination: {
            Dashboard(viewModel: TaskViewModel()).navigationBarBackButtonHidden(true)
        }).onAppear{
            IQKeyboardManager.shared.enable = true
        }.onDisappear{
            IQKeyboardManager.shared.enable = false
        }
    }
    
    private  func loginUser(){
        isloading = true
        NetworkManager.shared.loginUsers(username: username, password: password)
        { result in
            DispatchQueue.main.async {
                isloading = false
                switch result {
                case .success(let token):
                    alertMessage = "LoggedIn successful!"
//                    self.environmentObject(self.authManager.logIn())
                    self.authManager.logIn(token: token)
                    
                    navigateToLogin = true
//                    print("\(token)")
                    
                case .failure(let error):
                    alertMessage = "Login Failed!: \(error.localizedDescription)"
                }
                showALert = true
            }
        }
    }
}
}

#Preview {
    login()
}
