import SwiftUI

struct JoinHouseholdPlaceholderSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var householdSession: HouseholdSession

    @State private var homeCode = ""
    @State private var isJoining = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Enter home code") {
                    TextField("6-digit code", text: Binding(
                        get: { homeCode },
                        set: { newValue in
                            let digits = newValue.filter { $0.isNumber }
                            homeCode = String(digits.prefix(6))
                        }
                    ))
                    .keyboardType(.numberPad)
                }

                if let msg = householdSession.errorMessage, !msg.isEmpty {
                    Section {
                        Text(msg)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button {
                        Task { await join() }
                    } label: {
                        HStack {
                            if isJoining { ProgressView() }
                            Text("Join household")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                    }
                    .disabled(isJoining || homeCode.count != 6)
                }
            }
            .navigationTitle("Join")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @MainActor
    private func join() async {
        isJoining = true
        defer { isJoining = false }
        let result = await householdSession.joinHousehold(homeCode: homeCode)
        if result != nil {
            dismiss()
        }
    }
}

