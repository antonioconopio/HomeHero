//
//  RootView.swift
//  Frontend
//
//  Created by Antonio Conopio on 2026-01-17.
//

import SwiftUI

struct RootView: View {
    
    
    @State private var showSignedInView: Bool = false
    @StateObject private var householdSession = HouseholdSession()
    
    var body: some View {
        ZStack{
            if !showSignedInView {
                MainTabView(showSignedInView: $showSignedInView)
                    .environmentObject(householdSession)
            }
        }
        .onAppear{
            Task{
                let authUser = try? await AuthenticationManager.shared.getAuthenticatedUser()
                self.showSignedInView = authUser == nil
                if authUser == nil {
                    householdSession.clear()
                } else {
                    await householdSession.refresh()
                }
            }
        }
        .onChange(of: showSignedInView) { _, isShowingAuth in
            Task {
                if isShowingAuth {
                    householdSession.clear()
                } else {
                    await householdSession.refresh()
                }
            }
        }
        .fullScreenCover(isPresented: $showSignedInView){
            NavigationStack{
                AuthView(showSignedInView: $showSignedInView)
            }
        }
        
    }
}

#Preview {
    RootView()
}
