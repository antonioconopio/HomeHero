//
//  RootView.swift
//  Frontend
//
//  Created by Antonio Conopio on 2026-01-17.
//

import SwiftUI

struct RootView: View {
    
    @State private var showSignedInView: Bool = false
    @State private var isLoadingSession: Bool = true
    @StateObject private var householdSession = HouseholdSession()
    
    var body: some View {
        ZStack {
            if isLoadingSession {
                // Loading state while checking auth and fetching households
                loadingView
            } else if !showSignedInView {
                if householdSession.households.isEmpty {
                    // User is signed in but has no households - show onboarding
                    HouseholdOnboardingView()
                        .environmentObject(householdSession)
                } else {
                    // User is signed in and has households - show main app
                    MainTabView(showSignedInView: $showSignedInView)
                        .environmentObject(householdSession)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            Task {
                // DEV MODE: rely on persisted profile id.
                self.showSignedInView = (AuthenticationManager.shared.getPersistedProfileId() == nil)
                if !showSignedInView {
                    await householdSession.refresh()
                }
                isLoadingSession = false
            }
        }
        .onChange(of: showSignedInView) { newValue in
            // When user logs in (showSignedInView becomes false), refresh session
            if !newValue {
                isLoadingSession = true
                Task {
                    await householdSession.refresh()
                    isLoadingSession = false
                }
            }
        }
        // Listen for household changes to auto-transition when user creates/joins
        .onChange(of: householdSession.households) { _ in
            // Force view update when households change
        }
        .fullScreenCover(isPresented: $showSignedInView) {
            NavigationStack {
                AuthView(showSignedInView: $showSignedInView)
            }
        }
    }
    
    private var loadingView: some View {
        ZStack {
            AppColor.dropBackground.ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(AppColor.accentTeal)
                
                Text("Loading...")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
    }
}

#Preview {
    RootView()
}
