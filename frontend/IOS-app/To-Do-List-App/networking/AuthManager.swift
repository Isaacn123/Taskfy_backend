//
//  AuthManager.swift
//  To-Do-List-App
//
//  Created by Nsamba Isaac on 07/06/2024.
//

import SwiftUI
import Combine

class AuthManager:ObservableObject{
    
    @Published var isLoggedIn:Bool{
        didSet{
            UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
        }
    }
    
    @Published var token:String{
        didSet{
            UserDefaults.standard.set(token,forKey: "authToken")
        }
    }
    
    init(){
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        self.token = UserDefaults.standard.string(forKey: "authToken") ?? ""
    }
    
    func logIn(token:String){
        self.token = token
        isLoggedIn = true
    }
    
    func logOut(){
        token = ""
        isLoggedIn = false
    }
    
    func fetchTasksAndUpdateViewModel(viewModel: TaskViewModel) {
       
        if token.isEmpty {
               return
           }
        
        NetworkManager.shared.getallTasks(token: token){ result in
            switch result{
            case .success(let tasks):
//                print("Fetached tasks: \(tasks)")
//                var d:Array = []
                viewModel.tasks = tasks
                DispatchQueue.main.async {
                    viewModel.tasks = tasks
//                    for task in tasks{
//                        viewModel.tasks = tasks
//                        d.append(task)
//                    }
//                    d.append(tasks)
                    
                }
//                print("added Task:\(d)")
                print("After adding fetchedTasks: \(viewModel.tasks.count)")
            case .failure(let error):

                print("Error fetching tasks: \(error.localizedDescription)")
            }
        }
    }
    
    

}
