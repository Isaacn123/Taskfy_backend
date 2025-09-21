//
//  NetworkManager.swift
//  To-Do-List-App
//
//  Created by Nsamba Isaac on 04/06/2024.
//

import Foundation

struct NetworkManager{
    static let shared = NetworkManager()
//    let baseURL = "http://127.0.0.1:8000/"
//    let baseURL = "https://45.56.120.65:8000/"
    let baseURL = "https://45.56.120.65/"
//    @Published var user: User?
    
    private init() {}
    
    func registerUser(name:String,email:String,password:String, completion:@escaping(Result<Bool, Error>) -> Void)
    {
        let url  = URL(string: "\(baseURL)api/user")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String:String] = ["name":name,"email":email, "password":password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request){ data, response,error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse,httpResponse.statusCode == 200 else{
                
                completion(.failure(NSError(domain:"",code:0, userInfo:[NSLocalizedDescriptionKey:"Invalid response"])))
                return
            }
            
            completion(.success(true))
            
            print("Response status code: \(httpResponse.statusCode)")
            print("Response data: \(String(data: data, encoding: .utf8) ?? "No data")")
            
            
        }

        
        task.resume()
        
    }
    
    func getUser(token:String, completion:@escaping(Result<User, Error>) -> Void)
    {
        let url = URL(string: "\(baseURL)api/user/me")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let Usertask = URLSession.shared.dataTask(with: request){ data, response , error in
            
            
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            
            guard let data = data else {
                
                DispatchQueue.main.async {
                    
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                }
                return
            }
            
//            {} String(data:data, encoding: .utf8)
            do{ let user = try JSONDecoder().decode(User.self, from: data)  
                print("Respnse data: \n\(user)")
                
                DispatchQueue.main.sync{
                    completion(.success(user))
                }
                
                
            }catch {
                
                print("Failed to parse reponse data")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            
            
            
            print("Response data: \(String(data: data, encoding: .utf8) ?? "No data")")
            
            
        }
        
        Usertask.resume()
    
        
        
    }
    
    func loginUsers(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "\(baseURL)api/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json",forHTTPHeaderField:"accept")
        

        let parameters: [String: String] = ["username": username,"password": password]
//        let components = URLComponents()
//        components.queryItems = parameters.map { URLQueryItem(name: $0, value: $1)}
        let formData = parameters.map { "\($0)=\($1)" }.joined(separator: "&")
        
       
        
        let bodyString = formData  //components.percentEncodedQuery ?? ""
        

//        let bodyString = parameters.map { "\($0)=\($1)" }.joined(separator: "&")
        let bodyData = bodyString.data(using: .utf8)
        
        if let bodyData = bodyData {
            
            print("Body Data: \(bodyData.count)")
        } else {
            
            print("Failed to convert bodyString to Data")
            
        }

        request.httpBody = bodyData
        
//      print("DATA\(String(describing: bodyData))")

        let logintask = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            
            //            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            //                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
            //                return
            //            }
//            guard let httpResponse = response as? HTTPURLResponse else {
//                print("Invalid response")
//                return
//            }
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else{
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey:"Invalid response"])))
                return
            }
            
            //            if let tokenResponse = try? JSONDecoder().decode(TokenResponse.self, from: data) {
            //                completion(.success(tokenResponse.token))
            //            } else {
            //                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
            //            }
            
            if httpResponse.statusCode == 200 {
                print("Login successful")
            } else {
                print("Error: \(httpResponse.statusCode)")
            }
            
            guard let data = data, let token = String(data: data, encoding: .utf8) else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey:"Failed to parse token"])))
                }
                
                return
            }
            
            do{
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                completion(.success(tokenResponse.access_token))
                print("Response data: \(String(data: data, encoding: .utf8) ?? "No data")")
                      } catch {
                    completion(.failure(error))
                }
            
//            DispatchQueue.main.async {
//                completion(.success(token))
//                print("Response data: \(String(data: data, encoding: .utf8) ?? "No data")")
//            }
             
        }

        logintask.resume()
    }
    
    func createTask(title:String,token:String, completion:@escaping (Result<String,Error>) -> Void){
        let url = URL(string: "\(baseURL)api/user/tasks")!
         var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        print("TASK \(title)")
        let body: [String:String] = ["task_title":title]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        print("here Level")
        let tasks = URLSession.shared.dataTask(with: request) { data,response,error in
            print("here Level 3")
            if let error = error{
                DispatchQueue.main.async {
                    print("Error: \(error)")
                    completion(.failure(error))
                    return
                }
            }
            
            guard  let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else{
                completion(.failure(NSError(domain: "", code: 0, userInfo:[NSLocalizedDescriptionKey:"Invalid response"])))
                return
            }
            
            
            
            completion(.success("Task created successfully"))
            print("Task Response data: \(String(data: data, encoding: .utf8) ?? "No data")")
        }
        
//        request.httpBody =
        tasks.resume()
    }
    
    
    func getallTasks(token:String,completion:@escaping(Result<[Task],Error>)->Void){
        let url = URL(string: "\(baseURL)api/tasks")!
        var request = URLRequest(url: url)
        request.httpMethod = "Get"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let allTasks = URLSession.shared.dataTask(with: request){ data, response, error in
            
            if let error = error{
                DispatchQueue.main.async {
                    completion(.failure(error))
                    return
                }
            }
           
            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey:"invalid task respone"])))
                }
                return
            }
            
            do{
//                print("Raw Data: \(String(data: data, encoding: .utf8) ?? "No data")")
                let taskData = try JSONDecoder().decode([Task].self, from: data)
                     
                    DispatchQueue.main.async {
                        completion(.success(taskData))
//                        print("Response data DASA: \(String(data: data, encoding: .utf8) ?? "No data")")
                    }
                
                
            }catch{
                print("Raw ERROR: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                
                
            }
            
            
            
        }
        
        allTasks.resume()
    }
    

    func updateTasks(token:String,task_id:Int,is_completed:Bool,completion:@escaping(Result<Bool,Error>)->Void){
        let url = URL(string: "\(baseURL)api/task/\(task_id)")!
  
        let body:[String:Any] = ["is_completed":is_completed]
        
        // Create URL components
        var urlComponents = URLComponents(url: url,resolvingAgainstBaseURL: true)

        // Add query parameters to URL components
        urlComponents?.queryItems = body.map {
            
            print("KEY:\($0.key)")
            print("Value:\($0.value)")
            return URLQueryItem(name: $0.key, value: "\($0.value)")
            
//            URLQueryItem(name: $0.key, value: "\($0.value)")
        }

        // Construct the final URL
        if let finalURL = urlComponents?.url {
            print("OriginalURL:\(url)")
            print("Final URL: \(finalURL.absoluteString)")
            
            var request = URLRequest(url: finalURL)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            //        updateTask()
            
            
            print("Starting to initiate  update ")
            let updatetask = URLSession.shared.dataTask(with: request) { data, response, error in
                
//                if let data = data, let responseString = String(data: data, encoding: .utf8) {
//                    print("Response data string: \(responseString)")
//                } else if let error = error {
//                    print("Error: \(error.localizedDescription)")
//                }
                
                guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                                   DispatchQueue.main.async {
                                       
                                       completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey:"invalid Task Update response"])))
                                   }
                                   return
                               }
                
                
                            DispatchQueue.main.async {
                                    completion(.success(true))
                                }
                
                      print("Update response status code: \(httpResponse.statusCode)")
                      
                      print("Update response data: \(String(data: data, encoding: .utf8) ?? "No data")")
                
            }
            
            updatetask.resume()
        }
        else {
            print("Error constructing URL")
        }
    }
    
    
    func deleteTasks(token:String, task_id:Int,completion:@escaping(Result<Bool,Error>)->Void){
        let url = URL(string: "\(baseURL)api/task/\(task_id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let deleteTask = URLSession.shared.dataTask(with: request){ data, response, error in
            
            if let error = error{
                DispatchQueue.main.sync{
                    completion(.failure(error))
                }
            }
            
            guard let data = data, let httpResponse =  response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                
                DispatchQueue.main.sync {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey:" Invalid Task Response"])))
                }
                
                return
                
            }
            
            DispatchQueue.main.async {
                completion(.success(true))
            }
            return
        }
            deleteTask.resume()
        
    }
        
        
}

struct TokenResponse: Decodable{
    let access_token: String
    let token_type:String
}
