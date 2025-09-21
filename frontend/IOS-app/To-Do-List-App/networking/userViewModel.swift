//
//  userViewModel.swift
//  To-Do-List-App
//
//  Created by Nsamba Isaac on 10/06/2024.
//

import SwiftUI
import Combine

class UserDetailModel: ObservableObject {
    
    @Published var user:User?
    @Published var errormessage:String?
    
//    let baseURL = "http://127.0.0.1:8000/"
    let baseURL = "https://tasky.duckdns.org/app2/"
    
    
    func fetchUser(token:String){
//        NetworkManager.shared.getUser(token: token){ result in
//            
//            switch result {
//                
//            case .success(let user):
//                self.user = user
//                print("User info:\(user)")
//                
//            case .failure(let error):
//                self.errormessage = error.localizedDescription
//            }
//            
//        }
        
        let url = URL(string: "\(baseURL)api/user/me")!
              var request = URLRequest(url: url)
              request.httpMethod = "GET"
              request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
              
              let task = URLSession.shared.dataTask(with: request) { data, response, error in
                  guard let data = data, error == nil else {
                      print("Error fetching user: \(error?.localizedDescription ?? "Unknown error")")
                      return
                  }
                  
                  do {
                      let user = try JSONDecoder().decode(User.self, from: data)
                      DispatchQueue.main.async {
                          self.user = user
                      }
                  } catch {
                      print("Error decoding user: \(error.localizedDescription)")
                      print("user \(data)")
                  }
              }
              
              task.resume()
    }
    
}
