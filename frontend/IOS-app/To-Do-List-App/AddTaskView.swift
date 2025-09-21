//
//  AddTaskView.swift
//  To-Do-List-App
//
//  Created by Nsamba Isaac on 28/05/2024.
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var taskTitle = ""
    @ObservedObject var viewModel:TaskViewModel
    @EnvironmentObject var authManager:AuthManager
    @StateObject var userViewInfo:UserDetailModel
    @State private var  alertMessage = ""
    @State private var  navigateToLogin = false
    @State private var  showAlert = false
    @State private var  isloading = false
    
    
    var body: some View {
        NavigationStack{
            VStack{
                if isloading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(2)
                        .padding()
                }
                TextField("Task Title", text: $taskTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .submitLabel(.done)
                    .onSubmit {
                        createTask()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disableAutocorrection(true)
                    .autocapitalization(.words)
                Button(action: {
//                title: taskTitle, isCompleted: false,
//                    let newTask = Task(title: taskTitle, isCompleted: false, ownerId: userViewInfo.user?.id, dateCreated: user)
//                    viewModel.tasks.append(newTask)
                    createTask()
                    presentationMode.wrappedValue.dismiss()
                    
                }, label: {
                    Text("Add Task").padding()
                        .background(Color.yellow)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                })
            }
            .navigationTitle("Add Task")
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }.alert(isPresented: $navigateToLogin){
            Alert(title: Text(alertMessage))
        }
    }
    
    
    private func createTask(){
        isloading = true
        let token = authManager.token
        print("TOKE: \(token)")
        NetworkManager.shared.createTask(title: taskTitle, token: token){ result in
            print("am Inside")
            DispatchQueue.main.async {
                
                isloading = false
                
                switch result {
                case .success(let token):
                    alertMessage = "Task created successfully"
                    navigateToLogin = true
                    print("here is returned: \(token)")
                    getTasks()
                case .failure(let error):
                    
                    alertMessage = "Failed to create Task \(error.localizedDescription)"
                    
                }
                showAlert = true
            }
        }
    }
    
    private func getTasks(){
        let token = authManager.token
        NetworkManager.shared.getallTasks(token: token){ result in
            switch result{
            case .success(let task):
//                print("Fetached tasks: \(task)")
                print("tasks Fetched")
            case .failure(let error):
                print("Error fetching tasks: \(error.localizedDescription)")
            }
        }
    }
}

//#Preview {
//    AddTaskView(viewModel: TaskViewModel())
//}



struct AddTaskView_Previews:PreviewProvider{
    static var previews : some View{
        AddTaskView(viewModel: TaskViewModel(), userViewInfo: UserDetailModel())
    }
  }
