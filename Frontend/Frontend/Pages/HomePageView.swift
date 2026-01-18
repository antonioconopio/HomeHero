//
//  HomePageView.swift
//  HomeHero
//
//  Beautiful home dashboard with animated cards
//

import SwiftUI

struct HomePageView: View {
    @EnvironmentObject private var householdSession: HouseholdSession
    @State private var animateCards = false
    @State private var roommates: [HomeHeroAPI.Profile] = []
    @State private var isLoadingRoommates = false
    @State private var showInviteSheet = false
    @State private var showLeaveConfirmation = false

    var body: some View {
        NavigationStack {
            HouseholdGateView(
                title: "Join or create a household",
                subtitle: "To start using HomeHero, join a household or create one and invite your roommates."
            ) {
                ZStack {
                    // Background
                    AppColor.dropBackground.ignoresSafeArea()
                    AnimatedBackgroundOrbs()
                        .ignoresSafeArea()
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            // Hero Section
                            heroSection
                            
                            // Home Code Card
                            homeCodeSection
                            
                            // Roommates Section
                            roommatesSection
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColor.dropBackground.opacity(0.8), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                HouseholdSelectorToolbarItem()
            }
        }
        .task {
            await loadRoommates()
        }
        .onChange(of: householdSession.selectedHouseholdId) { _ in
            Task { await loadRoommates() }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateCards = true
            }
        }
        .sheet(isPresented: $showInviteSheet) {
            InviteRoommateSheet(onInvited: {
                Task { await loadRoommates() }
            })
            .environmentObject(householdSession)
        }
        .sheet(isPresented: $showLeaveConfirmation) {
            LeaveHouseholdConfirmationSheet()
                .environmentObject(householdSession)
        }
    }
    
    private func loadRoommates() async {
        guard let householdId = householdSession.selectedHouseholdId else {
            roommates = []
            return
        }
        
        isLoadingRoommates = true
        defer { isLoadingRoommates = false }
        
        do {
            let members = try await HomeHeroAPI.shared.getMembers(householdId: householdId)
            // Filter out the current user
            let myId = householdSession.me?.id
            await MainActor.run {
                roommates = members.filter { $0.id != myId }
            }
        } catch {
            await MainActor.run {
                roommates = []
            }
        }
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        VStack(spacing: 16) {
            ZStack {
                // Glow behind icon
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColor.accentTeal.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)
                
                // Icon container
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [AppColor.accentTeal.opacity(0.2), AppColor.accentSky.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [AppColor.accentTeal.opacity(0.5), AppColor.accentSky.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .frame(width: 72, height: 72)
                    
                    Image(systemName: "house.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColor.accentTeal, AppColor.accentSky],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            
            VStack(spacing: 8) {
                Text(householdSession.selectedHousehold?.name ?? "Home")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                
                Text("Your shared living dashboard")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .padding(.horizontal)
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 20)
    }
    
    // MARK: - Home Code Section
    
    private var homeCodeSection: some View {
        Group {
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
                                    .frame(width: 44, height: 44)
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(AppColor.accentAmber)
                            }
                        }
                        .accessibilityLabel("Copy home code")
                    }
                    .padding(16)
                }
                .padding(.horizontal)
                .opacity(animateCards ? 1 : 0)
                .offset(y: animateCards ? 0 : 30)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.12), value: animateCards)
            }
        }
    }
    
    // MARK: - Roommates Section
    
    private var roommatesSection: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "Roommates", subtitle: "\(roommates.count) in household")
                .padding(.horizontal)
            
            if isLoadingRoommates {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(AppColor.accentLavender)
                    Text("Loading roommates...")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(AppColor.textSecondary)
                }
                .padding(.vertical, 20)
            } else if roommates.isEmpty {
                GlassCard {
                    VStack(spacing: 12) {
                        Image(systemName: "person.2")
                            .font(.system(size: 36))
                            .foregroundStyle(AppColor.textTertiary)
                        Text("No roommates yet")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(AppColor.textSecondary)
                        Text("Share your home code or invite roommates by email")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundStyle(AppColor.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
                }
                .padding(.horizontal)
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(roommates.enumerated()), id: \.element.id) { index, roommate in
                        RoommateRow(profile: roommate)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 30)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15 + Double(index) * 0.05), value: animateCards)
                    }
                }
                .padding(.horizontal)
            }
            
            // Add Roommate Button
            Button {
                showInviteSheet = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Add Roommate")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppColor.accentLavender, AppColor.powderBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [AppColor.accentLavender.opacity(0.15), AppColor.powderBlue.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [AppColor.accentLavender.opacity(0.4), AppColor.powderBlue.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
            }
            .padding(.horizontal)
            .opacity(animateCards ? 1 : 0)
            .offset(y: animateCards ? 0 : 30)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.25), value: animateCards)
            
            // Leave Household Button
            Button {
                showLeaveConfirmation = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Leave Household")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(AppColor.accentCoral)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppColor.accentCoral.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(AppColor.accentCoral.opacity(0.3), lineWidth: 1)
                )
            }
            .padding(.horizontal)
            .opacity(animateCards ? 1 : 0)
            .offset(y: animateCards ? 0 : 30)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: animateCards)
        }
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 30)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15), value: animateCards)
    }
}

// MARK: - Supporting Views

struct RoommateRow: View {
    let profile: HomeHeroAPI.Profile
    
    private var displayName: String {
        let first = profile.firstName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let last = profile.lastName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let full = [first, last].filter { !$0.isEmpty }.joined(separator: " ")
        return full.isEmpty ? (profile.email ?? "Roommate") : full
    }
    
    private var initials: String {
        let first = profile.firstName?.trimmingCharacters(in: .whitespacesAndNewlines).first.map(String.init) ?? ""
        let last = profile.lastName?.trimmingCharacters(in: .whitespacesAndNewlines).first.map(String.init) ?? ""
        let combined = first + last
        return combined.isEmpty ? "?" : combined.uppercased()
    }
    
    var body: some View {
        GlassCard(accentColor: AppColor.accentLavender) {
            HStack(spacing: 14) {
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
                        .frame(width: 48, height: 48)
                    
                    Text(initials)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(displayName)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColor.textPrimary)
                    
                    if let email = profile.email, !email.isEmpty {
                        Text(email)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(AppColor.textSecondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Image(systemName: "person.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(AppColor.textTertiary)
            }
            .padding(16)
        }
    }
}

// MARK: - Invite Roommate Sheet

struct InviteRoommateSheet: View {
    @EnvironmentObject private var householdSession: HouseholdSession
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var searchResults: [HomeHeroAPI.Profile] = []
    @State private var selectedProfile: HomeHeroAPI.Profile?
    @State private var isSearching = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var searchTask: Task<Void, Never>?
    
    let onInvited: () -> Void
    
    private var emailToInvite: String {
        selectedProfile?.email ?? searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var isValidEmail: Bool {
        let email = emailToInvite
        return email.contains("@") && email.contains(".")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.dropBackground.ignoresSafeArea()
                AnimatedBackgroundOrbs()
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Header
                        headerSection
                        
                        // Search Card
                        searchCard
                        
                        // Search Results
                        if !searchResults.isEmpty && selectedProfile == nil {
                            searchResultsSection
                        }
                        
                        // Selected Profile Card
                        if let profile = selectedProfile {
                            selectedProfileCard(profile)
                        }
                        
                        // Messages
                        messagesSection
                        
                        Spacer(minLength: 20)
                        
                        // Send Button
                        sendButton
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
        }
    }
    
    // MARK: - Header
    
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
                    icon: "person.badge.plus",
                    colors: [AppColor.accentLavender, AppColor.powderBlue],
                    size: 72,
                    iconSize: 32
                )
            }
            
            VStack(spacing: 8) {
                Text("Invite Roommate")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                
                Text("Search by email to invite someone to your household")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Search Card
    
    private var searchCard: some View {
        GlassCard(accentColor: AppColor.accentLavender) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    GradientIconBadge(
                        icon: "magnifyingglass",
                        colors: [AppColor.accentLavender, AppColor.powderBlue],
                        size: 44,
                        iconSize: 18
                    )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Search by Email")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColor.textPrimary)
                        Text("Find existing users or enter a new email")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "envelope")
                        .font(.system(size: 16))
                        .foregroundStyle(AppColor.textTertiary)
                    
                    TextField("Enter email address", text: $searchText)
                        .font(.system(size: 16, design: .rounded))
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .foregroundStyle(AppColor.textPrimary)
                        .onChange(of: searchText) { newValue in
                            selectedProfile = nil
                            performSearch(query: newValue)
                        }
                    
                    if isSearching {
                        ProgressView()
                            .tint(AppColor.accentLavender)
                    } else if !searchText.isEmpty {
                        Button {
                            searchText = ""
                            searchResults = []
                            selectedProfile = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(AppColor.textTertiary)
                        }
                    }
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
        .padding(.horizontal)
    }
    
    // MARK: - Search Results
    
    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Search Results")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColor.textSecondary)
                .padding(.horizontal)
            
            VStack(spacing: 10) {
                ForEach(searchResults) { profile in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedProfile = profile
                            searchText = profile.email ?? ""
                        }
                    } label: {
                        SearchResultRow(profile: profile)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Selected Profile Card
    
    private func selectedProfileCard(_ profile: HomeHeroAPI.Profile) -> some View {
        GlassCard(accentColor: AppColor.accentMint) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColor.accentMint, AppColor.accentTeal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    
                    Text(initials(for: profile))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(displayName(for: profile))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColor.textPrimary)
                    
                    if let email = profile.email {
                        Text(email)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedProfile = nil
                        searchText = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(AppColor.textTertiary)
                }
            }
            .padding(16)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Messages
    
    private var messagesSection: some View {
        VStack(spacing: 12) {
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
            
            if let success = successMessage {
                GlassCard(accentColor: AppColor.accentMint) {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(AppColor.accentMint)
                        
                        Text(success)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(AppColor.textPrimary)
                        
                        Spacer()
                    }
                    .padding(16)
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Send Button
    
    private var sendButton: some View {
        Button {
            Task { await sendInvite() }
        } label: {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Send Invite")
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
                                colors: isValidEmail
                                    ? [AppColor.accentLavender, AppColor.powderBlue]
                                    : [AppColor.textTertiary, AppColor.textTertiary.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    if isValidEmail {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AppColor.shimmerGradient)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: isValidEmail ? AppColor.accentLavender.opacity(0.35) : .clear, radius: 16, x: 0, y: 8)
        }
        .disabled(!isValidEmail || isLoading)
        .padding(.horizontal)
    }
    
    // MARK: - Helpers
    
    private func performSearch(query: String) {
        searchTask?.cancel()
        
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else {
            searchResults = []
            return
        }
        
        searchTask = Task {
            isSearching = true
            defer { isSearching = false }
            
            // Debounce
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
            
            guard !Task.isCancelled else { return }
            
            do {
                let results = try await HomeHeroAPI.shared.searchProfiles(email: trimmed)
                
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    // Filter out current user and existing household members
                    let myId = householdSession.me?.id
                    searchResults = results.filter { $0.id != myId }
                }
            } catch {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    searchResults = []
                }
            }
        }
    }
    
    private func sendInvite() async {
        guard let householdId = householdSession.selectedHouseholdId else { return }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        defer { isLoading = false }
        
        do {
            try await HomeHeroAPI.shared.inviteToHousehold(householdId: householdId, email: emailToInvite)
            
            await MainActor.run {
                successMessage = "Invite sent to \(emailToInvite)"
                searchText = ""
                selectedProfile = nil
                searchResults = []
                onInvited()
                
                // Dismiss after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func displayName(for profile: HomeHeroAPI.Profile) -> String {
        let first = profile.firstName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let last = profile.lastName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let full = [first, last].filter { !$0.isEmpty }.joined(separator: " ")
        return full.isEmpty ? (profile.email ?? "User") : full
    }
    
    private func initials(for profile: HomeHeroAPI.Profile) -> String {
        let first = profile.firstName?.trimmingCharacters(in: .whitespacesAndNewlines).first.map(String.init) ?? ""
        let last = profile.lastName?.trimmingCharacters(in: .whitespacesAndNewlines).first.map(String.init) ?? ""
        let combined = first + last
        return combined.isEmpty ? "?" : combined.uppercased()
    }
}

// MARK: - Search Result Row

private struct SearchResultRow: View {
    let profile: HomeHeroAPI.Profile
    
    private var displayName: String {
        let first = profile.firstName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let last = profile.lastName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let full = [first, last].filter { !$0.isEmpty }.joined(separator: " ")
        return full.isEmpty ? (profile.email ?? "User") : full
    }
    
    private var initials: String {
        let first = profile.firstName?.trimmingCharacters(in: .whitespacesAndNewlines).first.map(String.init) ?? ""
        let last = profile.lastName?.trimmingCharacters(in: .whitespacesAndNewlines).first.map(String.init) ?? ""
        let combined = first + last
        return combined.isEmpty ? "?" : combined.uppercased()
    }
    
    var body: some View {
        GlassCard(accentColor: AppColor.accentLavender) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColor.accentLavender.opacity(0.3), AppColor.powderBlue.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Text(initials)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColor.accentLavender, AppColor.powderBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(displayName)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(AppColor.textPrimary)
                    
                    if let email = profile.email {
                        Text(email)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(AppColor.textSecondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColor.accentLavender, AppColor.powderBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(14)
        }
    }
}

// MARK: - Leave Household Confirmation Sheet

private struct LeaveHouseholdConfirmationSheet: View {
    @EnvironmentObject private var householdSession: HouseholdSession
    @Environment(\.dismiss) private var dismiss
    
    @State private var isLeaving = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.dropBackground.ignoresSafeArea()
                AnimatedBackgroundOrbs()
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    // Warning Icon
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [AppColor.accentCoral.opacity(0.3), .clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 60
                                )
                            )
                            .frame(width: 120, height: 120)
                            .blur(radius: 20)
                        
                        GradientIconBadge(
                            icon: "exclamationmark.triangle.fill",
                            colors: [AppColor.accentCoral, AppColor.accentAmber],
                            size: 80,
                            iconSize: 36
                        )
                    }
                    
                    // Text Content
                    VStack(spacing: 12) {
                        Text("Leave Household?")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColor.textPrimary)
                        
                        Text("Are you sure you want to leave")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundStyle(AppColor.textSecondary)
                        
                        if let householdName = householdSession.selectedHousehold?.name {
                            Text(householdName)
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [AppColor.accentLavender, AppColor.powderBlue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                    }
                    
                    // Warning Card
                    GlassCard(accentColor: AppColor.accentAmber) {
                        HStack(spacing: 14) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(AppColor.accentAmber)
                            
                            Text("If you're the last member, this household will be permanently deleted.")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundStyle(AppColor.textSecondary)
                        }
                        .padding(16)
                    }
                    .padding(.horizontal)
                    
                    if let error = errorMessage {
                        GlassCard(accentColor: AppColor.accentCoral) {
                            HStack(spacing: 12) {
                                Image(systemName: "xmark.circle.fill")
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
                    
                    Spacer()
                    
                    // Buttons
                    VStack(spacing: 12) {
                        // Leave Button
                        Button {
                            Task { await leaveHousehold() }
                        } label: {
                            HStack(spacing: 12) {
                                if isLeaving {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Leave Household")
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
                                                colors: [AppColor.accentCoral, AppColor.accentCoral.opacity(0.8)],
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
                        .disabled(isLeaving)
                        
                        // Cancel Button
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppColor.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(AppColor.surface)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(AppColor.textTertiary.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .disabled(isLeaving)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func leaveHousehold() async {
        guard let householdId = householdSession.selectedHouseholdId else { return }
        
        isLeaving = true
        errorMessage = nil
        defer { isLeaving = false }
        
        do {
            try await HomeHeroAPI.shared.leaveHousehold(householdId: householdId)
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
    HomePageView()
        .environmentObject(HouseholdSession())
}
