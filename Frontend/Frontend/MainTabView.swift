//
//  MainTabView.swift
//  HomeHero
//
//  Main tab navigation after login
//

import SwiftUI

struct MainTabView: View {
    @Binding var showSignedInView: Bool
    
    var body: some View {
        TabView {
            HomePageView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            TasksPageView()
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }
            
            ExpensesPageView()
                .tabItem {
                    Label("Expenses", systemImage: "dollarsign.circle.fill")
                }
            
            ProfilePageView(showSignedInView: $showSignedInView)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tint(AppColor.powderBlue)
    }
}

#Preview {
    MainTabView(showSignedInView: .constant(false))
}
