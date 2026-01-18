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
    @State private var showEditProfile = false

    @State private var animateContent = false

    // Show all invites received by the user (not sent by them)
    private var invitesToShow: [HomeHeroAPI.HouseholdInvite] {
        let meId = householdSession.me?.id
        return householdSession.invites.filter { inv in
            // Only show invites where the user is the invitee (not the inviter)
            if let meId, inv.inviterProfileId == meId { return false }
            return true
        }
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

                        // Balance Section (owed to others / owed to you)
                        balanceSection
                        
                        // Invites Section
                        invitesSection
                        
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColor.dropBackground.opacity(0.8), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                HouseholdSelectorToolbarItem()
            }
            .task {
                await householdSession.refresh()
                authEmail = try? await AuthenticationManager.shared.getAuthenticatedUser().email
            }
            .alert("Logout Error", isPresented: $showLogoutError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileSheet()
            }
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
                
                // Avatar with Edit Button
                ZStack(alignment: .bottomTrailing) {
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
                    
                    // Edit Button
                    Button {
                        showEditProfile = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(AppColor.surface)
                                .frame(width: 34, height: 34)
                                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                            
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [AppColor.accentLavender, AppColor.powderBlue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 30, height: 30)
                            
                            Image(systemName: "pencil")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .offset(x: 4, y: 4)
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
    
    // MARK: - Balance Section

    private var balanceSection: some View {
        VStack(spacing: 12) {
            // You Owe
            GlassCard(accentColor: AppColor.accentCoral) {
                HStack(spacing: 16) {
                    GradientIconBadge(
                        icon: "arrow.up.right.circle.fill",
                        colors: [AppColor.accentCoral, AppColor.accentAmber],
                        size: 48,
                        iconSize: 22
                    )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("You Owe")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(AppColor.textSecondary)
                        Text(formatCurrency(amountOwedValue))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppColor.accentCoral, AppColor.accentAmber],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    
                    Spacer()
                }
                .padding(18)
            }
            
            // Owed to You
            GlassCard(accentColor: AppColor.accentMint) {
                HStack(spacing: 16) {
                    GradientIconBadge(
                        icon: "arrow.down.left.circle.fill",
                        colors: [AppColor.accentMint, AppColor.accentTeal],
                        size: 48,
                        iconSize: 22
                    )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Owed to You")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(AppColor.textSecondary)
                        Text(formatCurrency(amountOwedToUserValue))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppColor.accentMint, AppColor.accentTeal],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    
                    Spacer()
                }
                .padding(18)
            }
        }
        .padding(.horizontal)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.12), value: animateContent)
    }
    
    // MARK: - Invites Section
    
    private var invitesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(
                title: "Household Invites",
                subtitle: invitesToShow.isEmpty ? "No pending invites" : "\(invitesToShow.count) pending"
            )
            .padding(.horizontal)

            if invitesToShow.isEmpty {
                // Empty state
                GlassCard(accentColor: AppColor.textTertiary) {
                    HStack(spacing: 14) {
                        GradientIconBadge(
                            icon: "envelope.open",
                            colors: [AppColor.textTertiary, AppColor.textTertiary.opacity(0.7)],
                            size: 48,
                            iconSize: 22
                        )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("No Invites")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppColor.textPrimary)
                            Text("You'll see household invitations here")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundStyle(AppColor.textSecondary)
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                }
                .padding(.horizontal)
            } else {
                VStack(spacing: 12) {
                    ForEach(invitesToShow) { inv in
                        InviteRow(invite: inv) {
                            Task { await householdSession.refresh() }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15), value: animateContent)
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
                    // Clear session data before switching views
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
        let backendEmail = householdSession.me?.email?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !backendEmail.isEmpty { return backendEmail }

        let supabaseEmail = (authEmail ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return supabaseEmail.isEmpty ? "Manage your account settings" : supabaseEmail
    }

    private var userScoreValue: Int {
        householdSession.me?.userScore ?? 0
    }

    private var amountOwedValue: Float {
        householdSession.me?.amountOwed ?? 0
    }

    private var amountOwedToUserValue: Float {
        householdSession.me?.amountOwedToUser ?? 0
    }

    private func formatCurrency(_ amount: Float) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
//        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// MARK: - Invite Row

private struct InviteRow: View {
    let invite: HomeHeroAPI.HouseholdInvite
    let onAction: () -> Void
    
    @State private var isAccepting = false
    @State private var isDeclining = false

    var body: some View {
        GlassCard(accentColor: AppColor.accentLavender) {
            VStack(spacing: 14) {
                HStack(spacing: 14) {
                    GradientIconBadge(
                        icon: "envelope.fill",
                        colors: [AppColor.accentLavender, AppColor.powderBlue],
                        size: 48,
                        iconSize: 22
                    )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(invite.householdAddress ?? "Household Invitation")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppColor.textPrimary)
                        
                        Text("You've been invited to join")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(AppColor.textSecondary)
                    }
                    
                    Spacer()
                }
                
                // Accept/Decline buttons
                if invite.status == "pending" || invite.status == nil {
                    HStack(spacing: 12) {
                        // Decline Button
                        Button {
                            Task { await declineInvite() }
                        } label: {
                            HStack(spacing: 6) {
                                if isDeclining {
                                    ProgressView()
                                        .tint(AppColor.accentCoral)
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Decline")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                }
                            }
                            .foregroundStyle(AppColor.accentCoral)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(AppColor.accentCoral.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(AppColor.accentCoral.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .disabled(isAccepting || isDeclining)
                        
                        // Accept Button
                        Button {
                            Task { await acceptInvite() }
                        } label: {
                            HStack(spacing: 6) {
                                if isAccepting {
                                    ProgressView()
                                        .tint(.white)
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Accept")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [AppColor.accentMint, AppColor.accentTeal],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        .disabled(isAccepting || isDeclining)
                    }
                } else {
                    // Show status badge for non-pending invites
                    HStack {
                        Spacer()
                        StatusBadge(
                            text: (invite.status ?? "pending").capitalized,
                            color: invite.status == "accepted" ? AppColor.accentMint : AppColor.accentCoral,
                            style: .outlined
                        )
                    }
                }
            }
            .padding(16)
        }
    }
    
    private func acceptInvite() async {
        isAccepting = true
        defer { isAccepting = false }
        
        do {
            try await HomeHeroAPI.shared.acceptInvite(inviteId: invite.id)
            await MainActor.run { onAction() }
        } catch {
            print("Failed to accept invite: \(error)")
        }
    }
    
    private func declineInvite() async {
        isDeclining = true
        defer { isDeclining = false }
        
        do {
            try await HomeHeroAPI.shared.declineInvite(inviteId: invite.id)
            await MainActor.run { onAction() }
        } catch {
            print("Failed to decline invite: \(error)")
        }
    }
}

// MARK: - Edit Profile Sheet

private struct EditProfileSheet: View {
    @EnvironmentObject private var householdSession: HouseholdSession
    @Environment(\.dismiss) private var dismiss
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.dropBackground.ignoresSafeArea()
                AnimatedBackgroundOrbs()
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Form Fields
                        formSection
                        
                        // Error Message
                        if let error = errorMessage {
                            GlassCard(accentColor: AppColor.accentCoral) {
                                HStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 20))
                                        .foregroundStyle(AppColor.accentCoral)
                                    
                                    Text(error)
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundStyle(AppColor.textPrimary)
                                    
                                    Spacer()
                                }
                                .padding(16)
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 20)
                        
                        // Save Button
                        saveButton
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
            .onAppear {
                firstName = householdSession.me?.firstName ?? ""
                lastName = householdSession.me?.lastName ?? ""
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColor.accentLavender.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)
                
                GradientIconBadge(
                    icon: "person.crop.circle",
                    colors: [AppColor.accentLavender, AppColor.powderBlue],
                    size: 72,
                    iconSize: 32
                )
            }
            
            VStack(spacing: 8) {
                Text("Edit Profile")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                
                Text("Update your personal information")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .padding(.horizontal)
    }
    
    private var formSection: some View {
        VStack(spacing: 16) {
            // First Name
            GlassCard(accentColor: AppColor.accentLavender) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("First Name")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(AppColor.textSecondary)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "person")
                            .font(.system(size: 16))
                            .foregroundStyle(AppColor.textTertiary)
                        
                        TextField("Enter first name", text: $firstName)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundStyle(AppColor.textPrimary)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppColor.surface2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(AppColor.textTertiary.opacity(0.2), lineWidth: 1)
                    )
                }
                .padding(18)
            }
            
            // Last Name
            GlassCard(accentColor: AppColor.powderBlue) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Last Name")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(AppColor.textSecondary)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "person")
                            .font(.system(size: 16))
                            .foregroundStyle(AppColor.textTertiary)
                        
                        TextField("Enter last name", text: $lastName)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundStyle(AppColor.textPrimary)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppColor.surface2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(AppColor.textTertiary.opacity(0.2), lineWidth: 1)
                    )
                }
                .padding(18)
            }
        }
        .padding(.horizontal)
    }
    
    private var saveButton: some View {
        Button {
            Task { await saveProfile() }
        } label: {
            HStack(spacing: 12) {
                if isSaving {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Save Changes")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [AppColor.accentLavender, AppColor.powderBlue],
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
            .shadow(color: AppColor.accentLavender.opacity(0.35), radius: 16, x: 0, y: 8)
        }
        .disabled(isSaving)
        .padding(.horizontal)
    }
    
    private func saveProfile() async {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        
        do {
            try await HomeHeroAPI.shared.updateProfile(
                firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            
            await householdSession.refresh()
            
            await MainActor.run {
                dismiss()
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    ProfilePageView(showSignedInView: .constant(false))
}
