//
//  register.swift
//  To-Do-List-App
//
//  Created by Nsamba Isaac on 25/05/2024.
//

import SwiftUI

struct register: View {
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var comfirmPassword = ""
    @State private var navigateToLogin = false
    @State private var alertMesaage = ""
    @State private var showAlert = false
    @State private var isloading = false
//    @ObservedObject private var keyboardObserver  = KeyboardObserver()
    
    var body: some View {
        if (navigateToLogin){
            
             login()
                    
                    
                }else {
                    
                    NavigationStack{
                              
                        ZStack{
                            Color(red:244/255, green: 194/255,blue: 127/255).ignoresSafeArea()
                            VStack{
                                Image("Done")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 200, height: 200)
                                Text("Get’s things done with TODO").frame(maxWidth:300).font(.title).multilineTextAlignment(.center)
                                
                                if isloading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .scaleEffect(2)
                                        .padding()
                                }
                                
                                VStack{
                                    
                                    Form{
                                        Section{
                                            TextField("Enter full name", text:$fullName)
                                        }
                                        Section{
                                            TextField("Enter your email", text:$email).autocapitalization(.none)
                                        }
                                        Section{
                                            SecureField("Enter password", text:$password).autocapitalization(.none)
                                        }
//                                        Section{
//                                            TextField("Comfirm Password", text:$comfirmPassword)
//                                        }
                                    }.background(Color.clear).scrollContentBackground(.hidden)
                                }
                                
                                Button(action: {
                                    registerUser()
                                }){
                                    Text("Register")
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: 300, maxHeight: 50).background(LinearGradient(gradient: Gradient(colors: [
                                    Color(red:244/255,green:194/255,blue:127/255),
                                    Color(red:216/255,green:96/255,blue:91/255)
                                ]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)).cornerRadius(25).shadow(radius: 1.5, x: 0, y: 0).padding()
                                
                                NavigationLink(value: navigateToLogin) {
                                    EmptyView()
                                    
                                }
                                //
                                //                    NavigationLink("", isActive: $navigateToLogin){
                                //
                                //
                                //
                                //                    }
                                
                                NavigationLink(destination:login().navigationBarBackButtonHidden(true)){ Text("Already have an account ? Sign In").foregroundColor(.white)}
                            }
                            
                        }
                                      
                                  
                              
                              
                          }.alert(isPresented: $showAlert){
                              Alert(title: Text(alertMesaage))
                          }.navigationDestination(isPresented: $navigateToLogin){
                              login().navigationBarBackButtonHidden(true)
                          }

                }
     
    }
    
    private func registerUser(){
        isloading = true
        NetworkManager.shared.registerUser(name: fullName, email: email, password:password){ result in
            DispatchQueue.main.async {
                isloading = false
                switch result {
                case .success:
                    alertMesaage = "Registeration Successful"
                    showAlert = true
                    navigateToLogin = true
                case .failure(let error):
                    alertMesaage = "Registration Failed: \(error.localizedDescription)"
                    showAlert = true
                    print("Registration error: \(error.localizedDescription)")
//                    print("Registration error: \()")
                }
            }
        }
    }
}

#Preview {
    register()
}
