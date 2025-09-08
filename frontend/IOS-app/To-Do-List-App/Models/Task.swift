//
//  Task.swift
//  To-Do-List-App
//
//  Created by Nsamba Isaac on 28/05/2024.
//

import Foundation

//struct Task:Identifiable, Decodable{
//    var id: UUID = UUID()
//    var title:String
//    var isCompleted:Bool
//}

struct Task:Identifiable, Decodable{
    
    var id:Int //UUID = UUID()
    var taskTitle:String
    var isCompleted:Bool
    var ownerId: Int
    var dateCreated: String
    
    private enum CodingKeys: String, CodingKey{
        
        case id
        case taskTitle = "task_title"
        case ownerId = "owner_id"
        case isCompleted = "is_completed"
        case dateCreated = "date_created"
    }
}
