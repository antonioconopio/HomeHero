//
//  ProfilePageView.swift
//  HomeHero
//
//  Profile page with logout functionality
//

import SwiftUI

struct ProfilePageView: View {
    @Binding var showSignedInView: Bool
    @State private var isLoggingOut = false
    @State private var showLogoutError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.mintCream.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Profile Header
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [AppColor.oxfordNavy, AppColor.regalNavy],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 44))
                                    .foregroundStyle(.white)
                            }
                            
                            Text("Your Profile")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(AppColor.oxfordNavy)
                            
                            Text("Manage your account settings")
                                .font(.system(size: 15, design: .rounded))
                                .foregroundStyle(AppColor.prussianBlue.opacity(0.70))
                        }
                        .padding(.top, 24)
                        
                        // Settings Section
                        VStack(spacing: 12) {
                            ProfileMenuItem(
                                icon: "person.circle.fill",
                                title: "Edit Profile",
                                color: AppColor.powderBlue
                            )
                            
                            ProfileMenuItem(
                                icon: "bell.fill",
                                title: "Notifications",
                                color: AppColor.powderBlue
                            )
                            
                            ProfileMenuItem(
                                icon: "gear",
                                title: "Settings",
                                color: AppColor.powderBlue
                            )
                            
                            ProfileMenuItem(
                                icon: "questionmark.circle.fill",
                                title: "Help & Support",
                                color: AppColor.powderBlue
                            )
                        }
                        .padding(.horizontal)
                        
                        // Logout Button
                        Button(action: performLogout) {
                            HStack(spacing: 12) {
                                if isLoggingOut {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Log out")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                }
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [AppColor.oxfordNavy, AppColor.regalNavy],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: AppColor.oxfordNavy.opacity(0.30), radius: 12, x: 0, y: 6)
                        }
                        .disabled(isLoggingOut)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        Text("Version 1.0.0")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(AppColor.prussianBlue.opacity(0.50))
                            .padding(.top, 8)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Logout Error", isPresented: $showLogoutError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func performLogout() {
        isLoggingOut = true
        
        Task {
            do {
                try await AuthenticationManager.shared.logout()
                
                await MainActor.run {
                    isLoggingOut = false
                    showSignedInView = true
                }
            } catch {
                await MainActor.run {
                    isLoggingOut = false
                    errorMessage = error.localizedDescription
                    showLogoutError = true
                }
            }
        }
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            Text(title)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(AppColor.oxfordNavy)
            
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
    ProfilePageView(showSignedInView: .constant(false))
}
