//
//  To_Do_List_AppApp.swift
//  To-Do-List-App
//
//  Created by Nsamba Isaac on 22/05/2024.
//

import SwiftUI
import IQKeyboardManagerSwift

@main
struct To_Do_List_AppApp: App {
    @StateObject private var authManager = AuthManager()
    
    init() {
        // Temporarily disable IQKeyboardManager to test if it's causing conflicts
        IQKeyboardManager.shared.enable = false
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView( viewModel: TaskViewModel()).environmentObject(authManager)
        }
    }
}
