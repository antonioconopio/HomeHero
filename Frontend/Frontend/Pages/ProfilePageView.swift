//
//  ProfilePageView.swift
//  HomeHero
//
//  Profile page with beautiful design and logout functionality
//

import SwiftUI

struct ProfilePageView: View {
    @Binding var showSignedInView: Bool
    @EnvironmentObject private var householdSession: HouseholdSession

    @State private var isLoggingOut = false
    @State private var showLogoutError = false
    @State private var errorMessage = ""
    @State private var authEmail: String?

    @State private var showCreateHousehold = false
    @State private var showJoinPlaceholder = false
    @State private var animateContent = false

    private var invitesToShow: [HomeHeroAPI.HouseholdInvite] {
        let meId = householdSession.me?.id
        let receivedOnly = householdSession.invites.filter { inv in
            if let meId, inv.inviterProfileId == meId { return false }
            return true
        }

        if let selectedId = householdSession.selectedHouseholdId {
            return receivedOnly.filter { $0.householdId == selectedId }
        }
        return receivedOnly
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.dropBackground.ignoresSafeArea()
                AnimatedBackgroundOrbs()
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Profile Header
                        profileHeader

                        // Score (prominent)
                        scoreSection
                        
                        // Household Section
                        householdSection
                        
                        // Invites Section
                        if !invitesToShow.isEmpty {
                            invitesSection
                        }
                        
                        // Settings Section
                        settingsSection
                        
                        // Logout Button
                        logoutSection
                        
                        // Version
                        Text("Version 1.0.0")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(AppColor.textTertiary)
                            .padding(.top, 8)
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColor.dropBackground.opacity(0.8), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .task {
                await householdSession.refresh()
                authEmail = try? await AuthenticationManager.shared.getAuthenticatedUser().email
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
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateContent = true
            }
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        VStack(spacing: 18) {
            ZStack {
                // Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColor.accentLavender.opacity(0.4), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 140)
                    .blur(radius: 25)
                
                // Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColor.accentLavender, AppColor.powderBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.3), .white.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: AppColor.accentLavender.opacity(0.4), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 44, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
            
            VStack(spacing: 6) {
                Text(displayName)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                
                Text(displayEmail)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .padding(.top, 24)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }
    
    // MARK: - Household Section
    
    private var householdSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Household", subtitle: "Manage your living space")
                .padding(.horizontal)

            VStack(spacing: 12) {
                if householdSession.households.isEmpty {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 12) {
                                GradientIconBadge(
                                    icon: "house.fill",
                                    colors: [AppColor.accentTeal, AppColor.accentSky],
                                    size: 44,
                                    iconSize: 20
                                )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("No household yet")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundStyle(AppColor.textPrimary)
                                    Text("Create or join a household to get started")
                                        .font(.system(size: 13, design: .rounded))
                                        .foregroundStyle(AppColor.textSecondary)
                                }
                            }
                        }
                        .padding(18)
                    }
                    .padding(.horizontal)
                } else {
                    // Household selector
                    GlassCard(accentColor: AppColor.accentTeal) {
                        Menu {
                            ForEach(householdSession.households) { h in
                                Button(h.name) { householdSession.selectHousehold(h.id) }
                            }
                        } label: {
                            HStack(spacing: 14) {
                                GradientIconBadge(
                                    icon: "house.fill",
                                    colors: [AppColor.accentTeal, AppColor.accentSky],
                                    size: 48,
                                    iconSize: 22
                                )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Active Household")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundStyle(AppColor.textTertiary)
                                    Text(householdSession.selectedHousehold?.name ?? "Select a household")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundStyle(AppColor.textPrimary)
                                }
                                Spacer()
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(AppColor.textTertiary)
                            }
                            .padding(16)
                        }
                    }
                    .padding(.horizontal)

                    // Home code card
                    if let code = householdSession.selectedHousehold?.homeCode, !code.isEmpty {
                        GlassCard(accentColor: AppColor.accentAmber) {
                            HStack(spacing: 14) {
                                GradientIconBadge(
                                    icon: "key.fill",
                                    colors: [AppColor.accentAmber, AppColor.accentCoral],
                                    size: 48,
                                    iconSize: 22
                                )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Home Code")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundStyle(AppColor.textTertiary)
                                    Text(code)
                                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [AppColor.accentAmber, AppColor.accentCoral],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                }
                                Spacer()
                                Button {
                                    UIPasteboard.general.string = code
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(AppColor.accentAmber.opacity(0.15))
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "doc.on.doc")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundStyle(AppColor.accentAmber)
                                    }
                                }
                                .accessibilityLabel("Copy home code")
                            }
                            .padding(16)
                        }
                        .padding(.horizontal)
                    }
                }

                // Action buttons
                HStack(spacing: 12) {
                    FloatingActionButton(
                        icon: "plus.circle.fill",
                        title: "Create",
                        colors: [AppColor.accentTeal, AppColor.accentSky]
                    ) {
                        showCreateHousehold = true
                    }

                    SecondaryButton(
                        icon: "person.2.fill",
                        title: "Join",
                        accentColor: AppColor.powderBlue
                    ) {
                        showJoinPlaceholder = true
                    }
                }
                .padding(.horizontal)
            }
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15), value: animateContent)
    }

    // MARK: - Score Section

    private var scoreSection: some View {
        GlassCard(accentColor: AppColor.accentAmber) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 10) {
                        GradientIconBadge(
                            icon: "bolt.fill",
                            colors: [AppColor.accentAmber, AppColor.accentCoral],
                            size: 44,
                            iconSize: 18
                        )

                        VStack(alignment: .leading, spacing: 2) {
                            Text("User Score")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(AppColor.textPrimary)
                            Text("Earn points by completing chores")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundStyle(AppColor.textSecondary)
                        }
                    }

                    Text("\(userScoreValue)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColor.accentAmber, AppColor.accentCoral],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("points")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColor.textTertiary)
                }

                Spacer()

                ZStack {
                    RingProgress(
                        progress: min(Double(userScoreValue) / 100.0, 1.0),
                        size: 72,
                        lineWidth: 7,
                        colors: [AppColor.accentAmber, AppColor.accentCoral]
                    )

                    VStack(spacing: 2) {
                        Text("\(userScoreValue)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColor.textPrimary)
                        Text("score")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppColor.textTertiary)
                    }
                }
            }
            .padding(18)
        }
        .padding(.horizontal)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.12), value: animateContent)
    }
    
    // MARK: - Invites Section
    
    private var invitesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Invites", subtitle: "\(invitesToShow.count) pending")
                .padding(.horizontal)

            VStack(spacing: 12) {
                ForEach(invitesToShow) { inv in
                    InviteRow(invite: inv)
                }
            }
            .padding(.horizontal)
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateContent)
    }
    
    // MARK: - Settings Section
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Settings")
                .padding(.horizontal)
            
            VStack(spacing: 10) {
                ProfileSettingsRow(
                    icon: "person.circle.fill",
                    title: "Edit Profile",
                    colors: [AppColor.accentLavender, AppColor.powderBlue]
                )
                
                ProfileSettingsRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    colors: [AppColor.accentCoral, AppColor.accentAmber]
                )
                
                ProfileSettingsRow(
                    icon: "gearshape.fill",
                    title: "Preferences",
                    colors: [AppColor.accentTeal, AppColor.accentSky]
                )
                
                ProfileSettingsRow(
                    icon: "questionmark.circle.fill",
                    title: "Help & Support",
                    colors: [AppColor.accentMint, AppColor.accentTeal]
                )
            }
            .padding(.horizontal)
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.25), value: animateContent)
    }
    
    // MARK: - Logout Section
    
    private var logoutSection: some View {
        Button(action: performLogout) {
            HStack(spacing: 14) {
                if isLoggingOut {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Log out")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [AppColor.accentCoral.opacity(0.9), AppColor.accentCoral.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppColor.shimmerGradient)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: AppColor.accentCoral.opacity(0.35), radius: 16, x: 0, y: 8)
        }
        .disabled(isLoggingOut)
        .padding(.horizontal)
        .padding(.top, 8)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: animateContent)
    }
    
    // MARK: - Actions
    
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

    private var displayName: String {
        let first = householdSession.me?.firstName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let last = householdSession.me?.lastName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let full = [first, last].filter { !$0.isEmpty }.joined(separator: " ")
        return full.isEmpty ? "Profile" : full
    }

    private var displayEmail: String {
        let backendEmail = householdSession.me?.email?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !backendEmail.isEmpty { return backendEmail }

        let supabaseEmail = (authEmail ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return supabaseEmail.isEmpty ? "Manage your account settings" : supabaseEmail
    }

    private var userScoreValue: Int {
        householdSession.me?.userScore ?? 0
    }
}

// MARK: - Profile Settings Row

struct ProfileSettingsRow: View {
    let icon: String
    let title: String
    let colors: [Color]
    
    var body: some View {
        GlassCard(accentColor: colors[0]) {
            HStack(spacing: 16) {
                GradientIconBadge(icon: icon, colors: colors, size: 46, iconSize: 20)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColor.textTertiary)
            }
            .padding(16)
        }
    }
}

// MARK: - Invite Row

private struct InviteRow: View {
    let invite: HomeHeroAPI.HouseholdInvite

    var body: some View {
        GlassCard(accentColor: AppColor.accentMint) {
            HStack(spacing: 14) {
                GradientIconBadge(
                    icon: "envelope.fill",
                    colors: [AppColor.accentMint, AppColor.accentTeal],
                    size: 48,
                    iconSize: 22
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(invite.householdAddress ?? "Household")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColor.textPrimary)

                    if let email = invite.inviteeEmail, !email.isEmpty {
                        Text(email)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }
                
                Spacer()

                StatusBadge(
                    text: (invite.status ?? "pending").capitalized,
                    color: AppColor.accentMint,
                    style: .outlined
                )
            }
            .padding(16)
        }
    }
}

#Preview {
    ProfilePageView(showSignedInView: .constant(false))
}
