//
//  ContentView.swift
//  To-Do-List-App
//
//  Created by Nsamba Isaac on 22/05/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var userDetail = UserDetailModel()
    @EnvironmentObject var authManager:AuthManager
    @ObservedObject var viewModel:TaskViewModel
    
    var body: some View {
        NavigationStack{
            
            ZStack{
                Color(red:244/255,green:194/255,blue:127/255,opacity:0.6).ignoresSafeArea()
                Spacer()
                VStack {
                    
                    Image("Done")
                        .imageScale(.medium)
                        .foregroundStyle(.tint)
                    Text("Welcome to our,")
                    VStack(spacing:10){
                        Text("OUR REMINDER").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Interdum dictum tempus, interdum at dignissim metus. Ultricies sed nunc.").multilineTextAlignment(.center).padding()
                    }
                    Spacer()
                    VStack{
                        
                       
                        
                        NavigationLink(destination: {
                          
                            login().navigationBarBackButtonHidden(true).onAppear{
                                authManager.fetchTasksAndUpdateViewModel(viewModel: viewModel)
                            }
                        }){
                            HStack(spacing:10){
                                Text("Get Started")
                                Image("arrow")
                            }.padding().foregroundColor(.white)
                        }.frame(maxWidth: .infinity).background(LinearGradient(gradient: Gradient(colors:[ Color(red:216/255,green:96/255,blue:91/255),
                                                                                Color(red:244/255,green:194/255,blue:127/255)                                                ]), startPoint: .leading, endPoint: .bottom)).cornerRadius(20)
        
                    }
                
              
                }
                .padding()
            }
            
        }  //navigationView
    }
    
//    private func getTasks(){
//        let token = authManager.token
//        NetworkManager.shared.getallTasks(token: token){ result in
//            switch result{
//            case .success(let tasks):
//                print("Fetached tasks: \(tasks)")
//                for task in tasks{
//                    viewModel.addTask(task: task)
//                }
//            case .failure(let error):
//                
//                print("Error fetching tasks: \(error.localizedDescription)")
//            }
//        }
//    }
}

#Preview {
    ContentView(viewModel: TaskViewModel())
}
