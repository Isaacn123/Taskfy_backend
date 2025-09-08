//
//  TaskViewModel.swift
//  To-Do-List-App
//
//  Created by Nsamba Isaac on 28/05/2024.
//
import SwiftUI
import Combine

class TaskViewModel: ObservableObject {
//    @Published var tasks: [Task] = [
////        Task( taskTitle: "sample Task 1", isCompleted: true,ownerId: 1,dateCreated: "2007"),
////        Task( taskTitle: "sample Task 2", isCompleted: false,ownerId: 1,dateCreated: "2007")
////        Task(id:1, taskTitle: "sample Task 1", isCompleted: true,ownerId: 1,dateCreated: "2007"),
////        Task(id:2, taskTitle: "sample Task 2", isCompleted: false,ownerId: 1,dateCreated: "2007")
//    ]
//    func addTask(task: Task) {
//        tasks.append(task)
//    }
    
    @Published var tasks: [Task] = []
    
    @Published var authManager = AuthManager()
    
    
    func deletetask(for task:Task){
        let token = authManager.token
        NetworkManager.shared.deleteTasks(token:token, task_id: task.id){ result in
            
            switch result {
            case .success(_):
                DispatchQueue.main.async{
                    self.tasks.removeAll{ $0.id == task.id}
                    print("Task Delete successfully \(task)")
                }
            case .failure(let error):
                DispatchQueue.main.async{
                    print("Error deleteing: \(error.localizedDescription)")
                }
            }
            
        }
    }
}
