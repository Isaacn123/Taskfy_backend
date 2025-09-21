//
//  Dashboard.swift
//  To-Do-List-App
//
//  Created by Nsamba Isaac on 28/05/2024.
//

import SwiftUI

struct Dashboard: View {
    @EnvironmentObject var authManager:AuthManager
    @StateObject private var userInfo = UserDetailModel()
    @ObservedObject var viewModel:TaskViewModel
    @Environment(\.colorScheme) var colorScheme
    var body: some View {

 // navigation View
        Group{
            
            if authManager.isLoggedIn {
                
                MainDashboard(viewModel: viewModel, userViewInfo: userInfo).onAppear{
                    fetchedTasks()
                    authManager.fetchTasksAndUpdateViewModel(viewModel: viewModel)
                }
                
            } else {
                
             login()
                
            }
        }
        
    }
    struct iOSCheckboxToggleStyle: ToggleStyle{
        func makeBody(configuration: Configuration) -> some View {
            Button(action:{
                configuration.isOn.toggle()
            }
                   , label: {
                HStack{
                    Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                    configuration.label
                }
            })
        }
    }
    

    
    private func fetchedTasks(){
        
        let token = authManager.token
        NetworkManager.shared.getallTasks(token: token){ result in
            switch result{
            case .success(let fetchedtasks):
//                print("Fetached tasks: \(fetchedtasks)")
                DispatchQueue.main.async {
                    viewModel.tasks = fetchedtasks
                     print("After adding FETCH DASHBOARD: \(viewModel.tasks.count)")
                }
            case .failure(let error):
                
                print("Error fetching tasks: \(error.localizedDescription)")
            }
        }
    }
    
    
    public struct MainDashboard: View {
        @State private var isOn = false
        @StateObject var viewModel = TaskViewModel()
        @EnvironmentObject var authManager:AuthManager
        @StateObject var userViewInfo:UserDetailModel
        @State private var is_nowCompleted = false
        @Environment(\.colorScheme) var colorScheme
        
        //        public init(userViewInfo: UserDetailModel) {
        //            _userViewInfo = StateObject(wrappedValue: userViewInfo)
        //        }
        
        
        var body: some View {
            NavigationView{
                
                ZStack{
                    Color(red: 244/255, green: 194/255, blue: 127/255).opacity(0.67).ignoresSafeArea()
                    
                    
                    VStack{
                        Image("profile")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .cornerRadius(50)
                            .padding(5)
                            .overlay(
                                Circle().stroke(Color(red: 216/255, green: 96/255, blue: 91/255), lineWidth: 3)
                            )
                        
                        if let user = userViewInfo.user{
                            Text("\(user.name)")
                            Text("\(user.email)")
                                .font(.footnote)
                                .foregroundColor(Color(red: 244/255, green: 94/255, blue: 91/255))
                        } else {
                            if let errormessage = userViewInfo.errormessage{
                                Text("Error: \(errormessage)")
                            }else{
                                Text("Loading user data..").onAppear{
                                    //                                    if let token = authManager.token {
                                    //                                        userViewInfo.fetchUser(token: token)
                                    //                                    }
                                    userViewInfo.fetchUser(token: authManager.token)
                                }
                            }
                        }
                        
                        
                        
                        Button(action: {
                            // Log out action
                            self.authManager.logOut()
                        }) {
                            Text("Log Out")
                                .padding(EdgeInsets(top: 10, leading: 50, bottom: 10, trailing: 50))
                                .background(Color(red: 244/255, green: 194/255, blue: 127/255))
                                .cornerRadius(20)
                                .foregroundColor(.black)
                        }
                        .padding(.bottom, 60)
                        
                        Form{
                            
                            Section(header: HStack {
                                Spacer()
                                VStack{
                                    
                                    Image("clock")
                                    Text("Good Afternoon").textCase(.none)
                                }
                                Spacer()
                            }.padding()) {
                                
                                
                                List{
                                    Section(header:
                                                HStack{
                                        Text("Tasks list")
                                        Spacer()
                                        NavigationLink(destination: AddTaskView(viewModel: viewModel, userViewInfo: UserDetailModel())){
                                            Image("plus")
                                        }
                                    }){
                                        
                                        //                                        Text("Total tasks: \(viewModel.tasks.count)").onAppear {
                                        //                                               print("Total tasks: \(viewModel.tasks.count)")
                                        //                                               for task in viewModel.tasks {
                                        //                                                   print("Task: \(task.taskTitle), Completed: \(task.isCompleted)")
                                        //                                               }
                                        //                                           }
                                        
                                        
                                        //  ForEach(viewModel.tasks){ task in

                                      
    ForEach(viewModel.tasks){ task in
                                            
      HStack{
                            Toggle(isOn: .constant(task.isCompleted)) {
                                Text(task.taskTitle)
                                    .foregroundColor(.black)
                            }.foregroundColor(.black).toggleStyle(iOSCheckboxToggleStyle())
                            
                            Spacer()

                                Toggle(isOn: $viewModel.tasks[self.index(for: task)].isCompleted) {
                                    //
                                }.onChange(of: viewModel.tasks[self.index(for: task)].isCompleted){
                                    updatetask(for: task)
                                }
                            Button(action: {
                              
                            }, label:{
                                Image(systemName: "pencil")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15,height: 15)
                                    .foregroundColor(.green)
                            })
          
                            Button(action: {
//                                deletetask(for: task)
                                viewModel.deletetask(for: task)
                            }, label: {
                                ZStack{
                                    
                                    Circle()
                                                  .fill(Color(white: colorScheme == .dark ? 0.19 : 0.93))
                                                  .frame(width: 20, height: 20)
                                
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .scaledToFit()
                                        .font(Font.body.weight(.bold))
                                        .scaleEffect(0.416)
                                        .foregroundColor(Color(white: colorScheme == .dark ? 0.62 : 0.51))
                                        .frame(width: 18, height: 18)  // Adjust the frame as needed
                                        .padding(.horizontal, 0)  // Ensure no horizontal padding
                                    
                                } //image background
                                                })
                                                
          Spacer()
                                                
                                                if task.isCompleted{
                                                    Text("Done").background(.red.opacity(0.5)).foregroundColor(.white.opacity(0.6))                                                          .foregroundColor(.black)
                                                    
                                                }
                                                }
                                                
                                            
                                        }
                                    }
                                    
                                    
                                    //    Toggle(isOn: $isOn) {
                                    //                                Text("Learn Reactjs at 12 pm")
                                    //                                    .foregroundColor(.black)
                                    //                            }.foregroundColor(.black).toggleStyle(iOSCheckboxToggleStyle())
                                    //
                                    // Toggle(isOn: $isOn) {
                                    //                                Text("Have Lunch at 1pm")
                                    //                                    .foregroundColor(.black)
                                    //
                                    
                                }
                            }
                        }
                        
                    }
                }
            }
            
        }
        
        private func index(for task: Task) -> Int {
            viewModel.tasks.firstIndex(where: { $0.id == task.id })!
        }
        
        private func toggleTask(_ task: Task) {
            if let index = viewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                viewModel.tasks[index].isCompleted.toggle()
            }
        }
        
        private func updatetask(for task:Task){
            let token = authManager.token
            let completed = task.isCompleted
            NetworkManager.shared.updateTasks(token: token, task_id: task.id, is_completed: completed){ result in
                
                switch result {
                case .success(let success):
                    DispatchQueue.main.async{
                        print("Task updated successfully: \(success)")
                    }
                case .failure(let error):
                    DispatchQueue.main.async{
                        print("failed to update:\(error.localizedDescription)")
                    }
                }
                
            }
        }
        
    }
    
}



#Preview {
    Dashboard(viewModel: TaskViewModel())
}
