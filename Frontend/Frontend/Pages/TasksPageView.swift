import SwiftUI
import Foundation

struct TasksPageView: View {
    @EnvironmentObject private var householdSession: HouseholdSession

    enum UpcomingWindow: String, CaseIterable, Identifiable {
        case next7Days = "Next 7 days"
        case nextMonth = "Next month"
        case next6Months = "Next 6 months"
        case all = "All"
        var id: String { rawValue }
    }

    @State private var chores: [HomeHeroAPI.Chore] = []
    @State private var membersById: [UUID: HomeHeroAPI.Profile] = [:]

    @State private var isLoading = false
    @State private var errorMessage: String?

    @State private var showCreateChore = false
    @State private var animateContent = false
    @State private var upcomingWindow: UpcomingWindow = .next7Days

    var body: some View {
        NavigationStack {
            HouseholdGateView(
                title: "Join or create a household",
                subtitle: "Tasks are household-specific. Join or create a household to begin."
            ) {
                ZStack {
                    AppColor.dropBackground.ignoresSafeArea()
                    AnimatedBackgroundOrbs()
                        .ignoresSafeArea()

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            header
                            content
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColor.dropBackground.opacity(0.8), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreateChore = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [AppColor.accentAmber.opacity(0.2), AppColor.accentCoral.opacity(0.15)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [AppColor.accentAmber, AppColor.accentCoral],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    }
                    .accessibilityLabel("Create chore")
                    .disabled(householdSession.selectedHousehold == nil)
                }
            }
            .task {
                await refresh()
            }
            .refreshable {
                await refresh()
            }
            .sheet(isPresented: $showCreateChore) {
                if let household = householdSession.selectedHousehold {
                    CreateChoreSheet(householdId: household.id, householdName: household.name) { req in
                        await createChore(in: household.id, request: req)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateContent = true
            }
        }
    }

    private var header: some View {
        VStack(spacing: 16) {
            ZStack {
                // Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColor.accentAmber.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)
                
                GradientIconBadge(
                    icon: "checklist",
                    colors: [AppColor.accentAmber, AppColor.accentCoral],
                    size: 72,
                    iconSize: 32
                )
            }

            VStack(spacing: 8) {
                Text("Chores")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)

                Text("Add chores, set due dates, and track impact.")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }

    private var content: some View {
        VStack(spacing: 16) {
            if let errorMessage {
                TaskErrorCard(message: errorMessage) {
                    Task { await refresh() }
                }
                .padding(.horizontal)
            }

            upcomingFilter

            if householdSession.selectedHousehold != nil {
                FloatingActionButton(
                    icon: "plus.circle.fill",
                    title: "Create chore",
                    colors: [AppColor.accentAmber, AppColor.accentCoral]
                ) {
                    showCreateChore = true
                }
                .padding(.horizontal)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 30)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15), value: animateContent)
            }

            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .tint(AppColor.accentAmber)
                    Text("Loading chores...")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(AppColor.textSecondary)
                }
                .padding(.top, 32)
            } else if chores.isEmpty {
                EmptyStateView(
                    icon: "checklist",
                    title: "No chores yet",
                    subtitle: "Tap + to create your first chore. Previous chores will show up here automatically.",
                    iconColors: [AppColor.accentAmber, AppColor.accentCoral]
                )
                .opacity(animateContent ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateContent)
            } else {
                VStack(spacing: 14) {
                    ForEach(Array(filteredChores.enumerated()), id: \.element.id) { index, chore in
                        ChoreRow(chore: chore, assigneeName: assigneeName(for: chore))
                            .environment(\.completeChoreAction, { id in
                                Task { await completeChore(id: id) }
                            })
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 40)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1 + Double(index) * 0.05), value: animateContent)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var upcomingFilter: some View {
        GlassCard(accentColor: AppColor.accentTeal) {
            HStack(spacing: 12) {
                GradientIconBadge(
                    icon: "calendar",
                    colors: [AppColor.accentTeal, AppColor.accentSky],
                    size: 44,
                    iconSize: 18
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Upcoming")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColor.textPrimary)
                    Text("Filter by due date window")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(AppColor.textSecondary)
                }

                Spacer()

                Menu {
                    ForEach(UpcomingWindow.allCases) { w in
                        Button(w.rawValue) { upcomingWindow = w }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text(upcomingWindow.rawValue)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(AppColor.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(AppColor.surface2)
                    )
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.08), lineWidth: 1)
                    )
                }
            }
            .padding(18)
        }
        .padding(.horizontal)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.12), value: animateContent)
    }

    private var filteredChores: [HomeHeroAPI.Chore] {
        let now = Date()

        let end: Date? = {
            switch upcomingWindow {
            case .next7Days:
                return Calendar.current.date(byAdding: .day, value: 7, to: now)
            case .nextMonth:
                return Calendar.current.date(byAdding: .month, value: 1, to: now)
            case .next6Months:
                return Calendar.current.date(byAdding: .month, value: 6, to: now)
            case .all:
                return nil
            }
        }()

        let filtered = chores.filter { chore in
            guard let due = effectiveDueDate(for: chore) else {
                return upcomingWindow == .all
            }
            guard let end else { return true }
            return due >= now && due <= end
        }

        return filtered.sorted { a, b in
            let da = effectiveDueDate(for: a) ?? .distantFuture
            let db = effectiveDueDate(for: b) ?? .distantFuture
            if da != db { return da < db }
            return a.title.localizedCaseInsensitiveCompare(b.title) == .orderedAscending
        }
    }

    private func effectiveDueDate(for chore: HomeHeroAPI.Chore) -> Date? {
        if let dueAt = chore.dueAt { return dueAt }

        // Fallback for date-range based chores if present.
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"

        if let start = chore.startDate, let d = f.date(from: start) { return d }
        return nil
    }

    @MainActor
    private func refresh() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            await householdSession.refresh()
            await loadMembers()
            await loadChores()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func loadMembers() async {
        guard let householdId = householdSession.selectedHousehold?.id else {
            membersById = [:]
            return
        }
        do {
            let members = try await HomeHeroAPI.shared.getMembers(householdId: householdId)
            membersById = Dictionary(uniqueKeysWithValues: members.map { ($0.id, $0) })
        } catch {
            membersById = [:]
        }
    }

    @MainActor
    private func loadChores() async {
        guard let householdId = householdSession.selectedHousehold?.id else {
            chores = []
            return
        }
        do {
            chores = try await HomeHeroAPI.shared.getChores(householdId: householdId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func createChore(in householdId: UUID, request: HomeHeroAPI.CreateChoreRequest) async {
        do {
            _ = try await HomeHeroAPI.shared.createChore(householdId: householdId, request: request)
            showCreateChore = false
            await loadMembers()
            await loadChores()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func completeChore(id: UUID) async {
        guard let householdId = householdSession.selectedHousehold?.id else { return }

        let previous = chores
        chores.removeAll { $0.id == id }

        do {
            try await HomeHeroAPI.shared.completeChore(householdId: householdId, choreId: id)
        } catch {
            chores = previous
            errorMessage = error.localizedDescription
        }
    }

    private func assigneeName(for chore: HomeHeroAPI.Chore) -> String? {
        guard let id = chore.assigneeId, let p = membersById[id] else { return nil }
        let first = (p.firstName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let last = (p.lastName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let full = [first, last].filter { !$0.isEmpty }.joined(separator: " ")
        if !full.isEmpty { return full }
        let email = (p.email ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return email.isEmpty ? nil : email
    }
}

// MARK: - Chore Row

private struct ChoreRow: View {
    let chore: HomeHeroAPI.Chore
    let assigneeName: String?
    @State private var isCompleted = false
    @Environment(\.completeChoreAction) private var completeChoreAction

    var body: some View {
        GlassCard(accentColor: AppColor.accentAmber) {
            HStack(spacing: 16) {
                // Checkbox with animation
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isCompleted.toggle()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: isCompleted
                                        ? [AppColor.accentMint, AppColor.accentTeal]
                                        : [AppColor.textTertiary, AppColor.textTertiary.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 28, height: 28)
                        
                        if isCompleted {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [AppColor.accentMint, AppColor.accentTeal],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 28, height: 28)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .buttonStyle(.plain)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(chore.title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(isCompleted ? AppColor.textTertiary : AppColor.textPrimary)
                        .strikethrough(isCompleted, color: AppColor.textTertiary)

                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                        Text(subtitleText(for: chore))
                            .font(.system(size: 13, design: .rounded))
                    }
                    .foregroundStyle(AppColor.textSecondary)
                }
                
                Spacer()

                VStack(alignment: .trailing, spacing: 10) {
                    ImpactBadge(impact: chore.impact)

                    if isCompleted {
                        Button {
                            completeChoreAction?(chore.id)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14, weight: .bold))
                                Text("Complete")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [AppColor.accentMint, AppColor.accentTeal],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .overlay(
                                Capsule()
                                    .stroke(.white.opacity(0.15), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(18)
        }
    }

    private func subtitleText(for chore: HomeHeroAPI.Chore) -> String {
        let due = dueText(for: chore)
        if let assigneeName, !assigneeName.isEmpty {
            return "\(due) • \(assigneeName)"
        }
        return due
    }

    private func dueText(for chore: HomeHeroAPI.Chore) -> String {
        if let dueAt = chore.dueAt {
            let f = DateFormatter()
            f.dateStyle = .medium
            f.timeStyle = .short
            return "Due \(f.string(from: dueAt))"
        }
        if let start = chore.startDate, let end = chore.endDate {
            return "\(start) → \(end)"
        }
        if let start = chore.startDate {
            return "Starts \(start)"
        }
        return "No due date"
    }
}

// MARK: - Environment action wiring

private struct CompleteChoreActionKey: EnvironmentKey {
    static let defaultValue: ((UUID) -> Void)? = nil
}

private extension EnvironmentValues {
    var completeChoreAction: ((UUID) -> Void)? {
        get { self[CompleteChoreActionKey.self] }
        set { self[CompleteChoreActionKey.self] = newValue }
    }
}

// MARK: - Impact Badge

private struct ImpactBadge: View {
    let impact: Int
    
    private var colors: [Color] {
        switch impact {
        case 1...3: return [AppColor.accentMint, AppColor.accentTeal]
        case 4...6: return [AppColor.accentAmber, AppColor.accentCoral.opacity(0.8)]
        default: return [AppColor.accentCoral, AppColor.accentAmber.opacity(0.8)]
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 10, weight: .bold))
            Text("\(impact)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
        }
        .foregroundStyle(
            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: colors.map { $0.opacity(0.15) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            Capsule()
                .stroke(
                    LinearGradient(
                        colors: colors.map { $0.opacity(0.4) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Error Card

private struct TaskErrorCard: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        GlassCard(accentColor: AppColor.accentCoral) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    GradientIconBadge(
                        icon: "exclamationmark.triangle.fill",
                        colors: [AppColor.accentCoral, AppColor.accentAmber],
                        size: 44,
                        iconSize: 20
                    )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Couldn't load data")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppColor.textPrimary)

                        Text(message)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(AppColor.textSecondary)
                            .lineLimit(2)
                    }
                }

                Button(action: retry) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Retry")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(AppColor.accentCoral)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(AppColor.accentCoral.opacity(0.15))
                    )
                }
            }
            .padding(18)
        }
    }
}

// MARK: - Create Chore Sheet

private struct CreateChoreSheet: View {
    @Environment(\.dismiss) private var dismiss

    enum ScheduleType: String, CaseIterable, Identifiable {
        case dueDate = "Due date"
        case dateRange = "Date range"
        var id: String { rawValue }
    }

    private let repeatOptions: [String] = [
        "never", "hourly", "daily", "weekdays", "weekends", "weekly", "biweekly",
        "monthly", "every 3 months", "every 6 months", "yearly"
    ]

    let householdId: UUID
    let householdName: String
    let onCreate: (_ request: HomeHeroAPI.CreateChoreRequest) async -> Void

    @State private var title = ""
    @State private var description = ""

    @State private var scheduleType: ScheduleType = .dueDate
    @State private var dueAt = Date()
    @State private var includeTime = false
    @State private var startDate = Date()
    @State private var endDate = Date()

    @State private var repeatRule = "never"

    @State private var members: [HomeHeroAPI.Profile] = []
    @State private var selectedProfileIds: Set<UUID> = []
    @State private var responsibleProfileId: UUID?
    @State private var membersError: String?
    @State private var isLoadingMembers = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.dropBackground.ignoresSafeArea()
                AnimatedBackgroundOrbs()
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        headerCard
                        
                        if let membersError {
                            errorCard(membersError)
                        }
                        
                        choreCard
                        scheduleCard

                        if rotationEligible {
                            rotationCard
                        } else {
                            responsibleCard
                        }

                        createButton
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Create Chore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColor.dropBackground.opacity(0.8), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppColor.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create") {
                        Task {
                            let req = buildRequest()
                            await onCreate(req)
                        }
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(canCreate ? AppColor.accentAmber : AppColor.textTertiary)
                    .disabled(!canCreate)
                }
            }
            .task {
                await loadMembers()
            }
            .onChange(of: repeatRule) { _ in
                if !rotationEligible {
                    selectedProfileIds = []
                    if responsibleProfileId == nil, let first = members.first?.id {
                        responsibleProfileId = first
                    }
                } else if selectedProfileIds.isEmpty && !members.isEmpty {
                    selectedProfileIds = Set(members.map(\.id))
                    responsibleProfileId = nil
                }
            }
        }
    }

    private var headerCard: some View {
        GlassCard(accentColor: AppColor.accentAmber) {
            HStack(spacing: 14) {
                GradientIconBadge(
                    icon: "checklist",
                    colors: [AppColor.accentAmber, AppColor.accentCoral],
                    size: 52,
                    iconSize: 24
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text("For \(householdName)")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColor.textSecondary)
                    Text("Add a chore")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColor.textPrimary)
                }

                Spacer()
            }
            .padding(18)
        }
    }

    private var choreCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Chore Details")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)

                SheetTextField(
                    placeholder: "Title (e.g. Clean washroom)",
                    text: $title
                )

                SheetTextField(
                    placeholder: "Description (optional)",
                    text: $description,
                    axis: .vertical
                )
            }
            .padding(18)
        }
    }

    private var scheduleCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Schedule")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)

                // Schedule type picker
                HStack(spacing: 8) {
                    ForEach(ScheduleType.allCases) { type in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                scheduleType = type
                            }
                        } label: {
                            Text(type.rawValue)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(scheduleType == type ? .white : AppColor.textSecondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(scheduleType == type
                                            ? LinearGradient(colors: [AppColor.accentAmber, AppColor.accentCoral], startPoint: .leading, endPoint: .trailing)
                                            : LinearGradient(colors: [AppColor.surface2, AppColor.surface2], startPoint: .leading, endPoint: .trailing)
                                        )
                                )
                        }
                    }
                }

                if scheduleType == .dueDate {
                    Toggle(isOn: $includeTime) {
                        Text("Include time")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundStyle(AppColor.textPrimary)
                    }
                    .tint(AppColor.accentAmber)

                    DatePicker(
                        "Due",
                        selection: $dueAt,
                        displayedComponents: includeTime ? [.date, .hourAndMinute] : [.date]
                    )
                    .tint(AppColor.accentAmber)
                    .foregroundStyle(AppColor.textPrimary)
                } else {
                    DatePicker("Start", selection: $startDate, displayedComponents: [.date])
                        .tint(AppColor.accentAmber)
                        .foregroundStyle(AppColor.textPrimary)
                    DatePicker("End", selection: $endDate, displayedComponents: [.date])
                        .tint(AppColor.accentAmber)
                        .foregroundStyle(AppColor.textPrimary)
                }

                // Repeat selector
                HStack {
                    Text("Repeat")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundStyle(AppColor.textPrimary)
                    Spacer()
                    Menu {
                        ForEach(repeatOptions, id: \.self) { opt in
                            Button(opt) { repeatRule = opt }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(repeatRule)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(AppColor.textPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(AppColor.surface2)
                        )
                    }
                }
            }
            .padding(18)
        }
    }

    private var rotationCard: some View {
        GlassCard(accentColor: AppColor.accentLavender) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Cycle")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColor.textPrimary)
                    Spacer()
                    StatusBadge(text: "Repeat is on", color: AppColor.accentLavender, style: .outlined)
                }

                Text("Select roommates for this chore's rotation cycle.")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(AppColor.textSecondary)

                if isLoadingMembers {
                    HStack(spacing: 10) {
                        ProgressView()
                            .tint(AppColor.accentLavender)
                        Text("Loading roommates...")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppColor.textSecondary)
                    }
                } else if members.isEmpty {
                    Text("No roommates found in this household yet.")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(AppColor.textSecondary)
                } else {
                    Button("Select all") {
                        selectedProfileIds = Set(members.map(\.id))
                    }
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColor.accentLavender)

                    VStack(spacing: 10) {
                        ForEach(members) { p in
                            Button {
                                toggleSelection(for: p.id)
                            } label: {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .stroke(
                                                selectedProfileIds.contains(p.id)
                                                    ? AppColor.accentLavender
                                                    : AppColor.textTertiary,
                                                lineWidth: 2
                                            )
                                            .frame(width: 24, height: 24)
                                        
                                        if selectedProfileIds.contains(p.id) {
                                            Circle()
                                                .fill(AppColor.accentLavender)
                                                .frame(width: 24, height: 24)
                                            
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundStyle(.white)
                                        }
                                    }

                                    Text(fullName(for: p))
                                        .font(.system(size: 15, weight: .medium, design: .rounded))
                                        .foregroundStyle(AppColor.textPrimary)

                                    Spacer()
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(AppColor.surface2)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Text("Assigned roommate will cycle through your selected list.")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(AppColor.textTertiary)
                }
            }
            .padding(18)
        }
    }

    private var responsibleCard: some View {
        GlassCard(accentColor: AppColor.accentTeal) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Responsible")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColor.textPrimary)
                    Spacer()
                    StatusBadge(text: "Repeat is off", color: AppColor.accentTeal, style: .outlined)
                }

                Text("Select the roommate responsible for this chore.")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(AppColor.textSecondary)

                if isLoadingMembers {
                    HStack(spacing: 10) {
                        ProgressView()
                            .tint(AppColor.accentTeal)
                        Text("Loading roommates...")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppColor.textSecondary)
                    }
                } else if members.isEmpty {
                    Text("No roommates found in this household yet.")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(AppColor.textSecondary)
                } else {
                    VStack(spacing: 10) {
                        ForEach(members) { p in
                            Button {
                                responsibleProfileId = p.id
                            } label: {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .stroke(
                                                (responsibleProfileId == p.id)
                                                    ? AppColor.accentTeal
                                                    : AppColor.textTertiary,
                                                lineWidth: 2
                                            )
                                            .frame(width: 24, height: 24)

                                        if responsibleProfileId == p.id {
                                            Circle()
                                                .fill(AppColor.accentTeal)
                                                .frame(width: 24, height: 24)

                                            Image(systemName: "checkmark")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundStyle(.white)
                                        }
                                    }

                                    Text(fullName(for: p))
                                        .font(.system(size: 15, weight: .medium, design: .rounded))
                                        .foregroundStyle(AppColor.textPrimary)

                                    Spacer()
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(AppColor.surface2)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(18)
        }
    }

    private var createButton: some View {
        FloatingActionButton(
            icon: "plus.circle.fill",
            title: "Create chore",
            colors: canCreate
                ? [AppColor.accentAmber, AppColor.accentCoral]
                : [AppColor.textTertiary, AppColor.textTertiary]
        ) {
            Task {
                let req = buildRequest()
                await onCreate(req)
            }
        }
        .disabled(!canCreate)
        .opacity(canCreate ? 1 : 0.55)
    }

    private func errorCard(_ message: String) -> some View {
        GlassCard(accentColor: AppColor.accentCoral) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    GradientIconBadge(
                        icon: "exclamationmark.triangle.fill",
                        colors: [AppColor.accentCoral, AppColor.accentAmber],
                        size: 40,
                        iconSize: 18
                    )
                    
                    Text("Couldn't load roommates")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColor.textPrimary)
                }

                Text(message)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(AppColor.textSecondary)

                Button("Retry") {
                    Task { await loadMembers() }
                }
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColor.accentCoral)
            }
            .padding(18)
        }
    }

    private var rotationEligible: Bool {
        repeatRule.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() != "never"
    }

    private var canCreate: Bool {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanTitle.isEmpty { return false }

        if rotationEligible {
            if isLoadingMembers { return false }
            if members.isEmpty { return false }
            if selectedProfileIds.isEmpty { return false }
        } else {
            if isLoadingMembers { return false }
            if members.isEmpty { return false }
            if responsibleProfileId == nil { return false }
        }
        return true
    }

    @MainActor
    private func loadMembers() async {
        isLoadingMembers = true
        membersError = nil
        defer { isLoadingMembers = false }

        do {
            let m = try await HomeHeroAPI.shared.getMembers(householdId: householdId)
            members = m
            // Apply defaults depending on repeat mode.
            if rotationEligible {
                if selectedProfileIds.isEmpty && !members.isEmpty {
                    selectedProfileIds = Set(members.map(\.id))
                }
                responsibleProfileId = nil
            } else {
                selectedProfileIds = []
                if responsibleProfileId == nil, let first = members.first?.id {
                    responsibleProfileId = first
                }
            }
        } catch {
            members = []
            membersError = error.localizedDescription
        }
    }

    private func toggleSelection(for id: UUID) {
        if selectedProfileIds.contains(id) {
            if selectedProfileIds.count > 1 {
                selectedProfileIds.remove(id)
            }
        } else {
            selectedProfileIds.insert(id)
        }
    }

    private func fullName(for p: HomeHeroAPI.Profile) -> String {
        let first = (p.firstName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let last = (p.lastName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let full = [first, last].filter { !$0.isEmpty }.joined(separator: " ")
        if !full.isEmpty { return full }
        let email = (p.email ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return email.isEmpty ? "Roommate" : email
    }

    private func buildRequest() -> HomeHeroAPI.CreateChoreRequest {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)

        let (dueAtValue, startStr, endStr): (Date?, String?, String?) = {
            switch scheduleType {
            case .dueDate:
                return (dueAt, nil, nil)
            case .dateRange:
                let f = DateFormatter()
                f.dateFormat = "yyyy-MM-dd"
                return (nil, f.string(from: startDate), f.string(from: endDate))
            }
        }()

        let shouldRotate = rotationEligible
        let rotateIds: [UUID]? = {
            guard shouldRotate else { return nil }
            return selectedProfileIds.isEmpty ? nil : Array(selectedProfileIds)
        }()

        return HomeHeroAPI.CreateChoreRequest(
            title: cleanTitle,
            description: cleanDescription.isEmpty ? nil : cleanDescription,
            dueAt: dueAtValue,
            startDate: startStr,
            endDate: endStr,
            repeatRule: repeatRule,
            rotateEnabled: shouldRotate,
            rotateWithProfileIds: rotateIds,
            assigneeId: shouldRotate ? nil : responsibleProfileId
        )
    }
}

// MARK: - Sheet Text Field

private struct SheetTextField: View {
    let placeholder: String
    @Binding var text: String
    var axis: Axis = .horizontal
    
    var body: some View {
        TextField(placeholder, text: $text, axis: axis)
            .textInputAutocapitalization(.sentences)
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
    }
}

#Preview {
    TasksPageView()
}
