import SwiftUI
import Foundation

struct TasksPageView: View {
    @EnvironmentObject private var householdSession: HouseholdSession

    @State private var chores: [HomeHeroAPI.Chore] = []

    @State private var isLoading = false
    @State private var errorMessage: String?

    @State private var showCreateChore = false

    var body: some View {
        NavigationStack {
            HouseholdGateView(
                title: "Join or create a household",
                subtitle: "Tasks are household-specific. Join or create a household to begin."
            ) {
                ZStack {
                    AppColor.mintCream.ignoresSafeArea()

                    ScrollView {
                        VStack(spacing: 18) {
                            header
                            content
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreateChore = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
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
                    CreateChoreSheet(householdName: household.name) { req in
                        await createChore(in: household.id, request: req)
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: "checklist")
                .font(.system(size: 52))
                .foregroundStyle(AppColor.oxfordNavy)

            Text("Chores")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppColor.oxfordNavy)

            Text("Add chores, set due dates, and track impact.")
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(AppColor.prussianBlue.opacity(0.70))
        }
        .padding(.horizontal)
    }

    private var content: some View {
        VStack(spacing: 12) {
            if let errorMessage {
                ErrorCard(message: errorMessage) {
                    Task { await refresh() }
                }
                .padding(.horizontal)
            }

            if householdSession.selectedHousehold != nil {
                Button {
                    showCreateChore = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Create chore")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                        Spacer()
                    }
                    .foregroundStyle(.white)
                    .padding(16)
                    .background(
                        LinearGradient(
                            colors: [AppColor.oxfordNavy, AppColor.regalNavy],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: AppColor.oxfordNavy.opacity(0.25), radius: 10, x: 0, y: 6)
                }
                .padding(.horizontal)
                .padding(.top, 4)
            }

            if isLoading {
                ProgressView()
                    .padding(.top, 24)
            } else if chores.isEmpty {
                EmptyStateCard(
                    title: "No chores yet",
                    subtitle: "Tap + to create your first chore. Previous chores will show up here automatically."
                )
                .padding(.horizontal)
            } else {
                VStack(spacing: 12) {
                    ForEach(chores) { chore in
                        ChoreRow(chore: chore)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    @MainActor
    private func refresh() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            await householdSession.refresh()
            await loadChores()
        } catch {
            errorMessage = error.localizedDescription
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
            await loadChores()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct ChoreRow: View {
    let chore: HomeHeroAPI.Chore

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "circle")
                .font(.system(size: 22))
                .foregroundStyle(AppColor.powderBlue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(chore.title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColor.oxfordNavy)

                Text(dueText(for: chore))
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(AppColor.prussianBlue.opacity(0.60))
            }
            
            Spacer()

            Text("Impact \(chore.impact)")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColor.oxfordNavy)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppColor.powderBlue.opacity(0.18))
                .clipShape(Capsule())
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private func dueText(for chore: HomeHeroAPI.Chore) -> String {
        if let dueAt = chore.dueAt {
            let f = DateFormatter()
            f.dateStyle = .medium
            f.timeStyle = .short
            return "Due \(f.string(from: dueAt))"
        }
        if let start = chore.startDate, let end = chore.endDate {
            return "Due \(start) → \(end)"
        }
        if let start = chore.startDate {
            return "Starts \(start)"
        }
        return "No due date"
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

private struct ErrorCard: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Couldn’t load data")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColor.oxfordNavy)

            Text(message)
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(AppColor.prussianBlue.opacity(0.75))

            Button("Retry", action: retry)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

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

    @State private var rotateEnabled = false
    @State private var rotateWithProfileIdsText = ""
    @State private var assigneeIdText = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Chore") {
                    TextField("Title (e.g. Clean washroom)", text: $title)
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }

                Section("Schedule") {
                    Picker("Type", selection: $scheduleType) {
                        ForEach(ScheduleType.allCases) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }

                    if scheduleType == .dueDate {
                        Toggle("Include time", isOn: $includeTime)
                        DatePicker("Due", selection: $dueAt, displayedComponents: includeTime ? [.date, .hourAndMinute] : [.date])
                    } else {
                        DatePicker("Start", selection: $startDate, displayedComponents: [.date])
                        DatePicker("End", selection: $endDate, displayedComponents: [.date])
                    }

                    Picker("Repeat", selection: $repeatRule) {
                        ForEach(repeatOptions, id: \.self) { opt in
                            Text(opt).tag(opt)
                        }
                    }
                }

                Section("Rotation (optional)") {
                    Toggle("Rotate between roommates", isOn: $rotateEnabled)
                    TextField("Rotate with profile UUIDs (comma separated)", text: $rotateWithProfileIdsText, axis: .vertical)
                        .lineLimit(2, reservesSpace: true)
                        .disabled(!rotateEnabled)
                }

                Section("Assignee (optional)") {
                    TextField("Assignee profile UUID", text: $assigneeIdText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .navigationTitle("Create Chore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create") {
                        Task {
                            let req = buildRequest()
                            await onCreate(req)
                        }
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func buildRequest() -> HomeHeroAPI.CreateChoreRequest {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)

        let rotateIds = parseUUIDList(rotateWithProfileIdsText)
        let assigneeId = UUID(uuidString: assigneeIdText.trimmingCharacters(in: .whitespacesAndNewlines))

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

        return HomeHeroAPI.CreateChoreRequest(
            title: cleanTitle,
            description: cleanDescription.isEmpty ? nil : cleanDescription,
            dueAt: dueAtValue,
            startDate: startStr,
            endDate: endStr,
            repeatRule: repeatRule,
            rotateEnabled: rotateEnabled,
            rotateWithProfileIds: rotateEnabled ? rotateIds : nil,
            assigneeId: assigneeId
        )
    }

    private func parseUUIDList(_ text: String) -> [UUID]? {
        let parts = text
            .split(whereSeparator: { $0 == "," || $0 == "\n" || $0 == " " || $0 == "\t" })
            .map { String($0) }
        let ids = parts.compactMap { UUID(uuidString: $0.trimmingCharacters(in: .whitespacesAndNewlines)) }
        return ids.isEmpty ? nil : ids
    }
}

#Preview {
    TasksPageView()
}
