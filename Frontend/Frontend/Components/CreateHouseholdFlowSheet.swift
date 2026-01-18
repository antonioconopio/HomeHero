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
            Form {
                Section("Household") {
                    TextField("Address (required)", text: $address)
                        .textInputAutocapitalization(.words)

                    Text("This becomes the household label for now.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Invite roommates (optional)") {
                    ForEach(roommateEmails.indices, id: \.self) { idx in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 10) {
                                TextField("Email", text: Binding(
                                    get: { roommateEmails[idx] },
                                    set: {
                                        roommateEmails[idx] = $0
                                        lookupResults[idx] = nil
                                        // trigger suggestions as user types
                                        scheduleSearch(at: idx)
                                    }
                                ))
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .keyboardType(.emailAddress)

                                Button {
                                    Task { await lookupEmail(at: idx) }
                                } label: {
                                    if isLookingUp.contains(idx) {
                                        ProgressView()
                                    } else {
                                        Image(systemName: "magnifyingglass")
                                    }
                                }
                                .buttonStyle(.borderless)
                                .disabled(roommateEmails[idx].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }

                            if let profile = lookupResults[idx] {
                                Text("Found: \(displayName(profile))")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }

                            if let opts = suggestions[idx], !opts.isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    ForEach(opts.prefix(5), id: \.id) { p in
                                        Button {
                                            applySuggestion(p, at: idx)
                                        } label: {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(displayName(p))
                                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                                        .foregroundStyle(AppColor.oxfordNavy)
                                                    Text(p.email ?? "")
                                                        .font(.system(size: 12, design: .rounded))
                                                        .foregroundStyle(AppColor.prussianBlue.opacity(0.65))
                                                }
                                                Spacer()
                                                Image(systemName: "arrow.up.left.circle.fill")
                                                    .foregroundStyle(AppColor.powderBlue)
                                            }
                                        }
                                        .buttonStyle(.plain)
                                        .padding(.vertical, 4)
                                    }
                                }
                                .padding(.top, 4)
                            }
                        }
                    }

                    Button {
                        roommateEmails.append("")
                    } label: {
                        Label("Add another roommate", systemImage: "plus")
                    }

                    if roommateEmails.count > 1 {
                        Button(role: .destructive) {
                            _ = roommateEmails.popLast()
                        } label: {
                            Label("Remove last", systemImage: "minus")
                        }
                    }
                }

                if let msg = householdSession.errorMessage, !msg.isEmpty {
                    Section {
                        Text(msg)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Create household")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .disabled(isCreating)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create") {
                        Task { await create() }
                    }
                    .disabled(isCreating || address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
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
        // cancel pending task
        searchTasks[idx]?.cancel()

        let q = roommateEmails[idx].trimmingCharacters(in: .whitespacesAndNewlines)
        if q.count < 2 {
            suggestions[idx] = []
            return
        }

        searchTasks[idx] = Task { [q] in
            try? await Task.sleep(nanoseconds: 300_000_000) // debounce
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
            // keep a "best match" hint
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

