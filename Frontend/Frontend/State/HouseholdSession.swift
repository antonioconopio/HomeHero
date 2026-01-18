import Foundation

@MainActor
final class HouseholdSession: ObservableObject {
    @Published var me: HomeHeroAPI.Profile?
    @Published var households: [HomeHeroAPI.Household] = []
    @Published var selectedHouseholdId: UUID?
    @Published var invites: [HomeHeroAPI.HouseholdInvite] = []

    @Published var isLoading = false
    @Published var errorMessage: String?

    private let selectedHouseholdKey = "selected_household_id"

    var selectedHousehold: HomeHeroAPI.Household? {
        guard let selectedHouseholdId else { return nil }
        return households.first(where: { $0.id == selectedHouseholdId })
    }

    init() {
        if let raw = UserDefaults.standard.string(forKey: selectedHouseholdKey),
           let id = UUID(uuidString: raw) {
            self.selectedHouseholdId = id
        }
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let profile = try await HomeHeroAPI.shared.getProfile()
            self.me = profile

            let myHouseholds = try await HomeHeroAPI.shared.getMyHouseholds()
            self.households = myHouseholds

            // Maintain selection if it still exists; otherwise pick first.
            if let selectedHouseholdId,
               myHouseholds.contains(where: { $0.id == selectedHouseholdId }) {
                // keep
            } else {
                selectedHouseholdId = myHouseholds.first?.id
                persistSelection()
            }

            let myInvites = try await HomeHeroAPI.shared.getMyInvites()
            self.invites = myInvites
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func selectHousehold(_ householdId: UUID?) {
        selectedHouseholdId = householdId
        persistSelection()
    }

    func createHousehold(address: String, roommateEmails: [String]) async -> HomeHeroAPI.Household? {
        let cleanAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanAddress.isEmpty else {
            errorMessage = "Address is required."
            return nil
        }

        do {
            let household = try await HomeHeroAPI.shared.createHousehold(address: cleanAddress, roommateEmails: roommateEmails)
            // Refresh lists + select the new household.
            await refresh()
            selectHousehold(household.id)
            return household
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func joinHousehold(homeCode: String) async -> HomeHeroAPI.Household? {
        let code = homeCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard code.count == 6 else {
            errorMessage = "Enter a 6-digit home code."
            return nil
        }
        do {
            let household = try await HomeHeroAPI.shared.joinHousehold(homeCode: code)
            await refresh()
            selectHousehold(household.id)
            return household
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    private func persistSelection() {
        if let selectedHouseholdId {
            UserDefaults.standard.set(selectedHouseholdId.uuidString, forKey: selectedHouseholdKey)
        } else {
            UserDefaults.standard.removeObject(forKey: selectedHouseholdKey)
        }
    }
}

