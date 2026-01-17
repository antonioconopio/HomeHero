//
//  ContentView.swift
//  Frontend
//
//  Created by Antonio Conopio on 2026-01-17.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var session: AppSession

    var body: some View {
        ZStack {
            // Global fallback background so future screens inherit the theme.
            AppColor.oxfordNavy.ignoresSafeArea()

            Group {
                if session.isLoggedIn {
                    HomeView()
                } else {
                    AuthDropInView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppSession())
}
