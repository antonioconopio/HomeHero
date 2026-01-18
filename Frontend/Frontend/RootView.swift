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
        .preferredColorScheme(.dark)
        .onAppear{
            Task{
                // DEV MODE: rely on persisted profile id.
                self.showSignedInView = (AuthenticationManager.shared.getPersistedProfileId() == nil)
                await householdSession.refresh()
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
