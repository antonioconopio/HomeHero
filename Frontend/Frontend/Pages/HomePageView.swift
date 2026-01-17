//
//  HomePageView.swift
//  HomeHero
//
//  Temporary home page placeholder
//

import SwiftUI

struct HomePageView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.mintCream.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(AppColor.oxfordNavy)
                    
                    Text("Welcome to HomeHero")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColor.oxfordNavy)
                    
                    Text("Your shared living dashboard")
                        .font(.system(size: 17, design: .rounded))
                        .foregroundStyle(AppColor.prussianBlue.opacity(0.70))
                    
                    Spacer()
                        .frame(height: 40)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        PlaceholderCard(
                            icon: "bell.fill",
                            title: "Notifications",
                            subtitle: "Stay updated with house activities"
                        )
                        
                        PlaceholderCard(
                            icon: "calendar",
                            title: "Upcoming Tasks",
                            subtitle: "See what's due this week"
                        )
                        
                        PlaceholderCard(
                            icon: "chart.bar.fill",
                            title: "Recent Expenses",
                            subtitle: "Track shared costs"
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PlaceholderCard: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(AppColor.powderBlue)
                .frame(width: 50, height: 50)
                .background(AppColor.powderBlue.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColor.oxfordNavy)
                
                Text(subtitle)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(AppColor.prussianBlue.opacity(0.60))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppColor.prussianBlue.opacity(0.30))
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    HomePageView()
}
