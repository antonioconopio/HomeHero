//
//  HomeHeroApp.swift
//  HomeHeroApp
//
//  Created by Antonio Conopio on 2026-01-17.
//

import SwiftUI

@main
struct HomeHeroApp: App {
    
    @State private var authManager = AuthenticationManager.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
