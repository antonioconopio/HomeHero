//
//  ProfilePageView.swift
//  HomeHero
//
//  Profile page with logout functionality
//

import SwiftUI

struct ProfilePageView: View {
    @Binding var showSignedInView: Bool
    @EnvironmentObject private var householdSession: HouseholdSession

    @State private var isLoggingOut = false
    @State private var showLogoutError = false
    @State private var errorMessage = ""

    @State private var showCreateHousehold = false
    @State private var showJoinPlaceholder = false

    private var invitesToShow: [HomeHeroAPI.HouseholdInvite] {
        let meId = householdSession.me?.id
        let receivedOnly = householdSession.invites.filter { inv in
            // defensive: never show invites you sent
            if let meId, inv.inviterProfileId == meId { return false }
            return true
        }

        // If a household is selected, show only invites for that household.
        if let selectedId = householdSession.selectedHouseholdId {
            return receivedOnly.filter { $0.householdId == selectedId }
        }
        return receivedOnly
    }
    
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
                            
                            Text(displayName)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(AppColor.oxfordNavy)
                            
                            Text(displayEmail)
                                .font(.system(size: 15, design: .rounded))
                                .foregroundStyle(AppColor.prussianBlue.opacity(0.70))
                        }
                        .padding(.top, 24)

                        // Household Section (drives other tabs)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Household")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(AppColor.oxfordNavy)
                                .padding(.horizontal)

                            VStack(spacing: 12) {
                                if householdSession.households.isEmpty {
                                    EmptyStateCard(
                                        title: "No household yet",
                                        subtitle: "Create a household and invite roommates to begin."
                                    )
                                } else {
                                    Menu {
                                        ForEach(householdSession.households) { h in
                                            Button(h.name) { householdSession.selectHousehold(h.id) }
                                        }
                                    } label: {
                                        HStack {
                                            Text(householdSession.selectedHousehold?.name ?? "Select a household")
                                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                                .foregroundStyle(AppColor.oxfordNavy)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundStyle(AppColor.prussianBlue.opacity(0.45))
                                        }
                                        .padding(14)
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                                    }

                                    if let code = householdSession.selectedHousehold?.homeCode, !code.isEmpty {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Home code")
                                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                                    .foregroundStyle(AppColor.prussianBlue.opacity(0.75))
                                                Text(code)
                                                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                                                    .foregroundStyle(AppColor.oxfordNavy)
                                            }
                                            Spacer()
                                            Button {
                                                UIPasteboard.general.string = code
                                            } label: {
                                                Image(systemName: "doc.on.doc")
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundStyle(AppColor.oxfordNavy)
                                            }
                                            .accessibilityLabel("Copy home code")
                                        }
                                        .padding(14)
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                                    }
                                }

                                HStack(spacing: 12) {
                                    Button {
                                        showCreateHousehold = true
                                    } label: {
                                        HStack(spacing: 10) {
                                            Image(systemName: "plus.circle.fill")
                                            Text("Create household")
                                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            Spacer()
                                        }
                                        .foregroundStyle(.white)
                                        .padding(14)
                                        .background(
                                            LinearGradient(
                                                colors: [AppColor.oxfordNavy, AppColor.regalNavy],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                        .shadow(color: AppColor.oxfordNavy.opacity(0.25), radius: 10, x: 0, y: 6)
                                    }

                                    Button {
                                        showJoinPlaceholder = true
                                    } label: {
                                        HStack(spacing: 10) {
                                            Image(systemName: "person.2.fill")
                                            Text("Join")
                                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            Spacer()
                                        }
                                        .foregroundStyle(AppColor.oxfordNavy)
                                        .padding(14)
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Invites Section (for roommates)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Invites")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(AppColor.oxfordNavy)
                                .padding(.horizontal)

                            if invitesToShow.isEmpty {
                                EmptyStateCard(
                                    title: "No invites",
                                    subtitle: householdSession.selectedHouseholdId == nil
                                    ? "Invites to join a household will show up here."
                                    : "No invites for the selected household."
                                )
                                .padding(.horizontal)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(invitesToShow) { inv in
                                        InviteRow(invite: inv)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
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
            .task {
                await householdSession.refresh()
            }
            .alert("Logout Error", isPresented: $showLogoutError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
        .sheet(isPresented: $showCreateHousehold) {
            CreateHouseholdFlowSheet()
                .environmentObject(householdSession)
        }
        .sheet(isPresented: $showJoinPlaceholder) {
            JoinHouseholdPlaceholderSheet()
                .environmentObject(householdSession)
        }
    }
    
    private func performLogout() {
        isLoggingOut = true
        
        Task {
            do {
                try await AuthenticationManager.shared.logout()
                
                await MainActor.run {
                    householdSession.clear()
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

    private var displayName: String {
        let first = householdSession.me?.firstName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let last = householdSession.me?.lastName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let full = [first, last].filter { !$0.isEmpty }.joined(separator: " ")
        return full.isEmpty ? "Profile" : full
    }

    private var displayEmail: String {
        let email = householdSession.me?.email?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return email.isEmpty ? "Manage your account settings" : email
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

private struct InviteRow: View {
    let invite: HomeHeroAPI.HouseholdInvite

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(invite.householdAddress ?? "Household")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColor.oxfordNavy)

            if let email = invite.inviteeEmail, !email.isEmpty {
                Text(email)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(AppColor.prussianBlue.opacity(0.65))
            }

            Text((invite.status ?? "pending").capitalized)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColor.oxfordNavy)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppColor.powderBlue.opacity(0.18))
                .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

private struct EmptyStateCard: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColor.oxfordNavy)
            Text(subtitle)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(AppColor.prussianBlue.opacity(0.70))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    ProfilePageView(showSignedInView: .constant(false))
}
