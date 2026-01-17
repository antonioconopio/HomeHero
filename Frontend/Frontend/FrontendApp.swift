//
//  FrontendApp.swift
//  Frontend
//
//  Created by Antonio Conopio on 2026-01-17.
//

import SwiftUI

@main
struct FrontendApp: App {
    @StateObject private var session = AppSession()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
        }
    }
}
