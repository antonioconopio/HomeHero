import SwiftUI

struct CreateHouseholdFlowSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var householdSession: HouseholdSession

    @State private var address = ""

    @State private var roommateEmails: [String] = [""]
    @State private var lookupResults: [Int: HomeHeroAPI.Profile] = [:]
    @State private var suggestions: [Int: [HomeHeroAPI.Profile]] = [:]
    @State private var isLookingUp: Set<Int> = []
    @State private var searchTasks: [Int: Task<Void, Never>] = [:]

    @State private var isCreating = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.dropBackground.ignoresSafeArea()
                AnimatedBackgroundOrbs()
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Header card
                        headerCard
                        
                        // Address card
                        addressCard
                        
                        // Roommates card
                        roommatesCard
                        
                        // Error message
                        if let msg = householdSession.errorMessage, !msg.isEmpty {
                            errorCard(msg)
                        }
                        
                        // Create button
                        createButton
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Create Household")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColor.dropBackground.opacity(0.8), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppColor.textSecondary)
                        .disabled(isCreating)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create") {
                        Task { await create() }
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(canCreate ? AppColor.accentTeal : AppColor.textTertiary)
                    .disabled(isCreating || !canCreate)
                }
            }
        }
    }
    
    private var canCreate: Bool {
        !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var headerCard: some View {
        GlassCard(accentColor: AppColor.accentTeal) {
            HStack(spacing: 14) {
                GradientIconBadge(
                    icon: "house.fill",
                    colors: [AppColor.accentTeal, AppColor.accentSky],
                    size: 56,
                    iconSize: 26
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("New Household")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(AppColor.textSecondary)
                    Text("Set up your living space")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColor.textPrimary)
                }
                
                Spacer()
            }
            .padding(18)
        }
    }
    
    private var addressCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    GradientIconBadge(
                        icon: "mappin.circle.fill",
                        colors: [AppColor.accentAmber, AppColor.accentCoral],
                        size: 36,
                        iconSize: 16
                    )
                    
                    Text("Household Name")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColor.textPrimary)
                }
                
                TextField("", text: $address, prompt: Text("Address or nickname").foregroundStyle(AppColor.textTertiary))
                    .textInputAutocapitalization(.words)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(AppColor.surface2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(AppColor.textTertiary.opacity(0.3), lineWidth: 1)
                    )
                
                Text("This becomes your household's display name")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(AppColor.textTertiary)
            }
            .padding(18)
        }
    }
    
    private var roommatesCard: some View {
        GlassCard(accentColor: AppColor.accentLavender) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 10) {
                    GradientIconBadge(
                        icon: "person.2.fill",
                        colors: [AppColor.accentLavender, AppColor.powderBlue],
                        size: 36,
                        iconSize: 16
                    )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Invite Roommates")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColor.textPrimary)
                        Text("Optional - you can invite later too")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(AppColor.textTertiary)
                    }
                }
                
                VStack(spacing: 12) {
                    ForEach(roommateEmails.indices, id: \.self) { idx in
                        roommateField(at: idx)
                    }
                }
                
                HStack(spacing: 12) {
                    Button {
                        roommateEmails.append("")
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Add roommate")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(AppColor.accentLavender)
                    }
                    
                    if roommateEmails.count > 1 {
                        Button {
                            _ = roommateEmails.popLast()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Remove")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(AppColor.accentCoral)
                        }
                    }
                }
            }
            .padding(18)
        }
    }
    
    private func roommateField(at idx: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                TextField("", text: Binding(
                    get: { roommateEmails[idx] },
                    set: {
                        roommateEmails[idx] = $0
                        lookupResults[idx] = nil
                        scheduleSearch(at: idx)
                    }
                ), prompt: Text("Email address").foregroundStyle(AppColor.textTertiary))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .font(.system(size: 16, design: .rounded))
                .foregroundStyle(AppColor.textPrimary)
                
                Button {
                    Task { await lookupEmail(at: idx) }
                } label: {
                    ZStack {
                        Circle()
                            .fill(AppColor.accentLavender.opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        if isLookingUp.contains(idx) {
                            ProgressView()
                                .tint(AppColor.accentLavender)
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(AppColor.accentLavender)
                        }
                    }
                }
                .disabled(roommateEmails[idx].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppColor.surface2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        lookupResults[idx] != nil
                            ? AppColor.accentMint.opacity(0.5)
                            : AppColor.textTertiary.opacity(0.2),
                        lineWidth: 1
                    )
            )
            
            if let profile = lookupResults[idx] {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColor.accentMint)
                    Text("Found: \(displayName(profile))")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(AppColor.accentMint)
                }
            }
            
            if let opts = suggestions[idx], !opts.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(opts.prefix(3), id: \.id) { p in
                        Button {
                            applySuggestion(p, at: idx)
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(AppColor.accentLavender.opacity(0.15))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 14))
                                        .foregroundStyle(AppColor.accentLavender)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(displayName(p))
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundStyle(AppColor.textPrimary)
                                    Text(p.email ?? "")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundStyle(AppColor.textSecondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "arrow.up.left.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(AppColor.accentLavender)
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(AppColor.surfaceElevated)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 4)
            }
        }
    }
    
    private func errorCard(_ message: String) -> some View {
        GlassCard(accentColor: AppColor.accentCoral) {
            HStack(spacing: 12) {
                GradientIconBadge(
                    icon: "exclamationmark.triangle.fill",
                    colors: [AppColor.accentCoral, AppColor.accentAmber],
                    size: 40,
                    iconSize: 18
                )
                
                Text(message)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(3)
            }
            .padding(16)
        }
    }
    
    private var createButton: some View {
        Button {
            Task { await create() }
        } label: {
            HStack(spacing: 14) {
                if isCreating {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                    Text("Create Household")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
                Spacer()
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            canCreate
                                ? LinearGradient(colors: [AppColor.accentTeal, AppColor.accentSky], startPoint: .leading, endPoint: .trailing)
                                : LinearGradient(colors: [AppColor.textTertiary, AppColor.textTertiary], startPoint: .leading, endPoint: .trailing)
                        )
                    
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppColor.shimmerGradient)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: canCreate ? AppColor.accentTeal.opacity(0.4) : .clear, radius: 16, x: 0, y: 8)
        }
        .disabled(isCreating || !canCreate)
        .opacity(canCreate ? 1 : 0.6)
    }

    private func displayName(_ p: HomeHeroAPI.Profile) -> String {
        let name = [p.firstName, p.lastName].compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }.joined(separator: " ")
        if !name.isEmpty { return name }
        return p.email ?? p.id.uuidString
    }

    @MainActor
    private func lookupEmail(at idx: Int) async {
        let q = roommateEmails[idx].trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }

        isLookingUp.insert(idx)
        defer { isLookingUp.remove(idx) }

        do {
            let results = try await HomeHeroAPI.shared.searchProfiles(email: q)
            lookupResults[idx] = results.first
            suggestions[idx] = results
        } catch {
            householdSession.errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func scheduleSearch(at idx: Int) {
        searchTasks[idx]?.cancel()

        let q = roommateEmails[idx].trimmingCharacters(in: .whitespacesAndNewlines)
        if q.count < 2 {
            suggestions[idx] = []
            return
        }

        searchTasks[idx] = Task { [q] in
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await runSearch(q: q, at: idx)
        }
    }

    @MainActor
    private func runSearch(q: String, at idx: Int) async {
        isLookingUp.insert(idx)
        defer { isLookingUp.remove(idx) }

        do {
            let results = try await HomeHeroAPI.shared.searchProfiles(email: q)
            suggestions[idx] = results
            lookupResults[idx] = results.first
        } catch {
            suggestions[idx] = []
        }
    }

    @MainActor
    private func applySuggestion(_ profile: HomeHeroAPI.Profile, at idx: Int) {
        if let email = profile.email, !email.isEmpty {
            roommateEmails[idx] = email
        }
        lookupResults[idx] = profile
        suggestions[idx] = []
    }

    @MainActor
    private func create() async {
        isCreating = true
        defer { isCreating = false }

        _ = await householdSession.createHousehold(address: address, roommateEmails: roommateEmails)
        if householdSession.selectedHousehold != nil {
            dismiss()
        }
    }
}
