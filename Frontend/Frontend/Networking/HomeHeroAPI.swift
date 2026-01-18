import Foundation

enum HomeHeroAPIError: Error, LocalizedError {
    case invalidURL
    case httpError(statusCode: Int, body: String?)
    case decodingError
    case encodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid server URL."
        case let .httpError(statusCode, body):
            if let body, !body.isEmpty {
                return "Server error (\(statusCode)): \(body)"
            }
            return "Server error (\(statusCode))."
        case .decodingError:
            return "Could not decode server response."
        case .encodingError:
            return "Could not encode request."
        }
    }
}

final class HomeHeroAPI {
    static let shared = HomeHeroAPI()

    // NOTE: If running on a physical iPhone, replace localhost with your Mac's LAN IP.
    private let baseURLString = "http://localhost:8080/homeHero/api/v1"
    private let profileIdDefaultsKey = "logged_in_profile_id"
    private let profileIdHeaderName = "X-Profile-Id"

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init(session: URLSession = .shared) {
        self.session = session

        let d = JSONDecoder()
        d.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)

            // Spring/Jackson often emits fractional seconds; Apple's .iso8601 decoder does not always accept them.
            let withFractional = ISO8601DateFormatter()
            withFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            let withoutFractional = ISO8601DateFormatter()
            withoutFractional.formatOptions = [.withInternetDateTime]

            if let date = withFractional.date(from: raw) ?? withoutFractional.date(from: raw) {
                return date
            }
            throw HomeHeroAPIError.decodingError
        }
        self.decoder = d

        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        self.encoder = e
    }

    // MARK: - DTOs

    struct Household: Codable, Identifiable, Hashable {
        let id: UUID
        let name: String
        let address: String?
        let homeCode: String?
        let score: Int
        let createdAt: Date?
    }

    struct Profile: Codable, Identifiable, Hashable {
        let id: UUID
        let balance: Int?
        let userScore: Int?
        let firstName: String?
        let lastName: String?
        let email: String?
        let phoneNumber: String?
        let amountOwed: Float?
        let amountOwedToUser: Float?
    }

    struct HouseholdInvite: Codable, Identifiable, Hashable {
        let id: UUID
        let householdId: UUID
        let inviterProfileId: UUID
        let inviteeProfileId: UUID?
        let inviteeEmail: String?
        let status: String?
        let createdAt: Date?
        let householdAddress: String?
    }

    struct Chore: Codable, Identifiable, Hashable {
        let id: UUID
        let householdId: UUID
        let title: String
        let description: String?
        let dueAt: Date?
        let startDate: String?
        let endDate: String?
        let repeatRule: String?
        let rotateEnabled: Bool?
        let rotateWithJson: String?
        let assigneeId: UUID?
        let impact: Int
        let createdAt: Date?
    }

    struct CreateHouseholdRequest: Codable {
        let name: String?
        let address: String
        let roommateEmails: [String]?
    }

    struct CreateChoreRequest: Codable {
        let title: String
        let description: String?
        let dueAt: Date?
        let startDate: String?
        let endDate: String?
        let repeatRule: String
        let rotateEnabled: Bool
        let rotateWithProfileIds: [UUID]?
        // Used only when repeatRule == "never" (single responsible roommate).
        let assigneeId: UUID?
    }

    struct JoinHouseholdRequest: Codable {
        let homeCode: String
    }

    // MARK: - Expense DTOs

    struct ExpenseSplit: Codable, Identifiable, Hashable {
        let id: UUID
        let expenseId: UUID
        let profileId: UUID
        let amount: Float
        let paid: Bool
    }

    struct Expense: Codable, Identifiable, Hashable {
        let id: UUID
        let householdId: UUID
        let profileId: UUID
        let item: String
        let cost: Float
        let score: Int
        let createdAt: Date?
        let splits: [ExpenseSplit]?
    }

    struct CreateExpenseRequest: Codable {
        let profileId: UUID
        let item: String
        let cost: Float
        let score: Int
        let profileIds: [UUID]?
    }
    
    struct Grocery: Codable, Identifiable, Hashable {
        let id: UUID?
        let profileId: UUID?
        let groceryName: String?
        let createdAt: String?  // Keep as String to avoid date parsing issues
        let householdId: UUID?
        
        // Computed property for display
        var displayName: String {
            groceryName ?? "Unnamed Item"
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case profileId = "profile_id"
            case groceryName = "grocery_name"
            case createdAt = "created_at"
            case householdId = "household_id"
        }
    }
    
    struct CreateGroceryRequest: Codable {
        let groceryName: String
        let householdId: UUID
        
        enum CodingKeys: String, CodingKey {
            case groceryName = "grocery_name"
            case householdId = "household_id"
        }
    }
    
    struct UpdateGroceryRequest: Codable {
        let id: UUID
        let groceryName: String
        let householdId: UUID
        
        enum CodingKeys: String, CodingKey {
            case id
            case groceryName = "grocery_name"
            case householdId = "household_id"
        }
    }

    // MARK: - Public API

    func getProfile() async throws -> Profile {
        let url = try buildURL(path: "/getProfile")
        let req = makeRequest(url: url, method: "GET")
        return try await send(req, as: Profile.self)
    }

    func getHouseholds() async throws -> [Household] {
        let url = try buildURL(path: "/households")
        let req = makeRequest(url: url, method: "GET")
        return try await send(req, as: [Household].self)
    }

    func getMyHouseholds() async throws -> [Household] {
        let url = try buildURL(path: "/my/households")
        let req = makeRequest(url: url, method: "GET")
        return try await send(req, as: [Household].self)
    }

    func getMyInvites() async throws -> [HouseholdInvite] {
        let url = try buildURL(path: "/my/invites")
        let req = makeRequest(url: url, method: "GET")
        return try await send(req, as: [HouseholdInvite].self)
    }

    func searchProfiles(email: String) async throws -> [Profile] {
        let encoded = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? email
        let url = try buildURL(path: "/profiles/search?email=\(encoded)")
        let req = makeRequest(url: url, method: "GET")
        return try await send(req, as: [Profile].self)
    }

    func createHousehold(address: String, roommateEmails: [String]) async throws -> Household {
        let url = try buildURL(path: "/households")
        let cleanEmails = roommateEmails
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let body = CreateHouseholdRequest(
            name: nil,
            address: address,
            roommateEmails: cleanEmails.isEmpty ? nil : cleanEmails
        )
        let req = try makeJSONRequest(url: url, method: "POST", body: body)
        return try await send(req, as: Household.self)
    }

    func joinHousehold(homeCode: String) async throws -> Household {
        let url = try buildURL(path: "/households/join")
        let body = JoinHouseholdRequest(homeCode: homeCode)
        let req = try makeJSONRequest(url: url, method: "POST", body: body)
        return try await send(req, as: Household.self)
    }

    func getMembers(householdId: UUID) async throws -> [Profile] {
        let url = try buildURL(path: "/households/\(householdId.uuidString)/members")
        let req = makeRequest(url: url, method: "GET")
        return try await send(req, as: [Profile].self)
    }

    func addMember(householdId: UUID, profileId: UUID) async throws {
        let url = try buildURL(path: "/households/\(householdId.uuidString)/members")
        let body = ["profileId": profileId.uuidString]
        let req = try makeJSONRequest(url: url, method: "POST", body: body)
        _ = try await send(req, as: EmptyResponse.self)
    }

    func inviteToHousehold(householdId: UUID, email: String) async throws {
        let url = try buildURL(path: "/households/\(householdId.uuidString)/invite")
        let body = ["email": email]
        let req = try makeJSONRequest(url: url, method: "POST", body: body)
        _ = try await send(req, as: EmptyResponse.self)
    }

    func leaveHousehold(householdId: UUID) async throws {
        let url = try buildURL(path: "/households/\(householdId.uuidString)/leave")
        let req = makeRequest(url: url, method: "POST")
        _ = try await send(req, as: EmptyResponse.self)
    }

    func getChores(householdId: UUID) async throws -> [Chore] {
        let url = try buildURL(path: "/households/\(householdId.uuidString)/chores")
        let req = makeRequest(url: url, method: "GET")
        return try await send(req, as: [Chore].self)
    }

    func createChore(householdId: UUID, request: CreateChoreRequest) async throws -> Chore {
        let url = try buildURL(path: "/households/\(householdId.uuidString)/chores")
        let req = try makeJSONRequest(url: url, method: "POST", body: request)
        return try await send(req, as: Chore.self)
    }

    func completeChore(householdId: UUID, choreId: UUID) async throws {
        let url = try buildURL(path: "/households/\(householdId.uuidString)/chores/\(choreId.uuidString)/complete")
        let req = makeRequest(url: url, method: "POST")
        _ = try await send(req, as: EmptyResponse.self)
    }

    // MARK: - Expenses API

    func getExpenses(householdId: UUID) async throws -> [Expense] {
        let url = try buildURL(path: "/expenses/households/\(householdId.uuidString)")
        let req = makeRequest(url: url, method: "GET")
        return try await send(req, as: [Expense].self)
    }

    func getExpense(expenseId: UUID) async throws -> Expense {
        let url = try buildURL(path: "/expenses/\(expenseId.uuidString)")
        let req = makeRequest(url: url, method: "GET")
        return try await send(req, as: Expense.self)
    }

    func getMonthlyTotal(householdId: UUID) async throws -> Float {
        let url = try buildURL(path: "/expenses/households/\(householdId.uuidString)/monthly-total")
        let req = makeRequest(url: url, method: "GET")
        return try await send(req, as: Float.self)
    }

    func getMySplits(householdId: UUID) async throws -> [ExpenseSplit] {
        let url = try buildURL(path: "/expenses/households/\(householdId.uuidString)/my-splits")
        let req = makeRequest(url: url, method: "GET")
        return try await send(req, as: [ExpenseSplit].self)
    }

    func createExpense(householdId: UUID, payerProfileId: UUID, item: String, cost: Float, splitWithProfileIds: [UUID]?) async throws -> Expense {
        let url = try buildURL(path: "/expenses/households/\(householdId.uuidString)/expenses")
        let body = CreateExpenseRequest(
            profileId: payerProfileId,
            item: item,
            cost: cost,
            score: 0,
            profileIds: splitWithProfileIds
        )
        let req = try makeJSONRequest(url: url, method: "POST", body: body)
        return try await send(req, as: Expense.self)
    }

    func deleteExpense(expenseId: UUID) async throws {
        let url = try buildURL(path: "/expenses/\(expenseId.uuidString)")
        let req = makeRequest(url: url, method: "DELETE")
        _ = try await send(req, as: EmptyResponse.self)
    }

    func markSplitAsPaid(splitId: UUID) async throws {
        let url = try buildURL(path: "/expenses/splits/\(splitId.uuidString)/mark-paid")
        let req = makeRequest(url: url, method: "POST")
        _ = try await send(req, as: EmptyResponse.self)
    }

    func markSplitAsUnpaid(splitId: UUID) async throws {
        let url = try buildURL(path: "/expenses/splits/\(splitId.uuidString)/mark-unpaid")
        let req = makeRequest(url: url, method: "POST")
        _ = try await send(req, as: EmptyResponse.self)
    }

    // MARK: - Profile API

    func updateProfile(firstName: String, lastName: String) async throws -> Profile {
        let url = try buildURL(path: "/profile")
        let body = ["firstName": firstName, "lastName": lastName]
        let req = try makeJSONRequest(url: url, method: "PUT", body: body)
        return try await send(req, as: Profile.self)
    }

    // MARK: - Invites API

    func acceptInvite(inviteId: UUID) async throws {
        let url = try buildURL(path: "/invites/\(inviteId.uuidString)/accept")
        let req = makeRequest(url: url, method: "POST")
        _ = try await send(req, as: EmptyResponse.self)
    }

    func declineInvite(inviteId: UUID) async throws {
        let url = try buildURL(path: "/invites/\(inviteId.uuidString)/decline")
        let req = makeRequest(url: url, method: "POST")
        _ = try await send(req, as: EmptyResponse.self)
    }
    
    // MARK: - Grocery API
    
    func getGroceries(householdId: UUID) async throws -> [Grocery] {
        let url = try buildURL(path: "/getGrocery?household_id=\(householdId.uuidString)")
        let req = makeRequest(url: url, method: "GET")
        return try await send(req, as: [Grocery].self)
    }

    func createGrocery(householdId: UUID, name: String) async throws -> Grocery {
        let url = try buildURL(path: "/insertGrocery")
        let body = CreateGroceryRequest(groceryName: name, householdId: householdId)
        let req = try makeJSONRequest(url: url, method: "POST", body: body)
        return try await send(req, as: Grocery.self)
    }

    func deleteGrocery(_ grocery: Grocery) async throws -> Grocery {
        let url = try buildURL(path: "/deleteGrocery")
        let req = try makeJSONRequest(url: url, method: "DELETE", body: grocery)
        return try await send(req, as: Grocery.self)
    }
    
    func updateGrocery(id: UUID, householdId: UUID, name: String) async throws -> Grocery {
        let url = try buildURL(path: "/updateGrocery")
        let body = UpdateGroceryRequest(id: id, groceryName: name, householdId: householdId)
        let req = try makeJSONRequest(url: url, method: "PUT", body: body)
        return try await send(req, as: Grocery.self)
    }

    // MARK: - Helpers

    private struct EmptyResponse: Codable {}

    private func buildURL(path: String) throws -> URL {
        guard let url = URL(string: baseURLString + path) else { throw HomeHeroAPIError.invalidURL }
        return url
    }

    private func makeRequest(url: URL, method: String) -> URLRequest {
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        // DEV MODE identity propagation.
        if let profileId = UserDefaults.standard.string(forKey: profileIdDefaultsKey) {
            req.setValue(profileId, forHTTPHeaderField: profileIdHeaderName)
        }
        return req
    }

    private func makeJSONRequest<T: Encodable>(url: URL, method: String, body: T) throws -> URLRequest {
        var req = makeRequest(url: url, method: method)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            req.httpBody = try encoder.encode(body)
        } catch {
            throw HomeHeroAPIError.encodingError
        }
        return req
    }

    private func send<T: Decodable>(_ request: URLRequest, as: T.Type) async throws -> T {
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw HomeHeroAPIError.httpError(statusCode: -1, body: nil)
        }
        guard (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8)
            throw HomeHeroAPIError.httpError(statusCode: http.statusCode, body: body)
        }
        if T.self == EmptyResponse.self {
            return EmptyResponse() as! T
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw HomeHeroAPIError.decodingError
        }
    }
}

