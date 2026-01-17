//
//  RootView.swift
//  Frontend
//
//  Created by Antonio Conopio on 2026-01-17.
//

import SwiftUI

struct RootView: View {
    
    
    @State private var showSignedInView: Bool = false
    
    var body: some View {
        ZStack{
            ContentView()
        }
        .onAppear{
            Task{
                let authUser = try? await AuthenticationManager.shared.getAuthenticatedUser()
                self.showSignedInView = authUser == nil
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
