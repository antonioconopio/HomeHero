import Foundation
import Supabase
internal import Combine

struct AppUser: Codable {
    let uid: String
    let email: String?
    let data: UserData?
    
    struct UserData: Codable {
        let firstName: String
        let lastName: String
        let phone: String
    }

    init(session: Session) {
        self.uid = session.user.id.uuidString
        self.email = session.user.email
        
        let metadata = session.user.userMetadata
        
        // Extract string values from AnyJSON
        let firstName = metadata["first_name"]?.stringValue
        let lastName = metadata["last_name"]?.stringValue
        let phone = metadata["phone"]?.stringValue
        
        if let firstName = firstName,
           let lastName = lastName,
           let phone = phone {
            self.data = UserData(
                firstName: firstName,
                lastName: lastName,
                phone: phone
            )
        } else {
            self.data = nil
        }
    }
}

class AuthenticationManager: ObservableObject {
    
    static let shared = AuthenticationManager()
    private init () {}
    
    @Published var authToken: String? = nil

    // DEV MODE: Persist the "logged in" profile UUID in UserDefaults.
    // This is not secure and is meant only for rapid prototyping.
    private let profileIdKey = "logged_in_profile_id"

    func getPersistedProfileId() -> UUID? {
        guard let raw = UserDefaults.standard.string(forKey: profileIdKey) else { return nil }
        return UUID(uuidString: raw)
    }

    private func persistProfileId(_ id: UUID?) {
        if let id {
            UserDefaults.standard.set(id.uuidString, forKey: profileIdKey)
        } else {
            UserDefaults.standard.removeObject(forKey: profileIdKey)
        }
    }
    
    let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://yszsamtouruajsjzavhp.supabase.co")!,
        supabaseKey: "sb_publishable_9Mg1A2V1ech_MQcknQHZvA_JOmeyheG"
    )
    
    func getAuthenticatedUser() async throws -> AppUser {
        let session = try await supabase.auth.session
        return AppUser(session: session)
        
    }
    
    @discardableResult
    func createUser(
        email: String,
        password: String,
        firstname: String,
        lastname: String,
        phone: String
    ) async throws -> AppUser {

        let response = try await supabase.auth.signUp(
            email: email,
            password: password,
            data: [
                "first_name": .string(firstname),
                "last_name": .string(lastname),
                "phone_number": .string(phone),
                "email": .string(email)
            ]
        )
        
        guard let session = response.session else {
            print("no session")
            throw NSError()
        }
        
        // Set Auth Token
        await MainActor.run {
            self.authToken = session.accessToken
        }
        
        // DEV MODE: Use Supabase user id as our backend profile id.
        persistProfileId(session.user.id)
        
        print("signed up! \(session.user)")

        return AppUser(session: session)
    }


    @discardableResult
    func signInUser(email: String, password: String) async throws -> AppUser {
        let session = try await supabase.auth.signIn(email: email, password: password)
        
        // Set Auth Token
        await MainActor.run {
            self.authToken = session.accessToken
        }
        
        // DEV MODE: Use Supabase user id as our backend profile id.
        persistProfileId(session.user.id)
        
        
        print("signed in! \(session.user)")
        return AppUser(session: session)
    }
    
    func reAuthenticate() async throws {
        try await supabase.auth.reauthenticate()
    }
    
//    func resetPasswordForEmail(email: String) async throws {
//        try await supabase.auth.resetPasswordForEmail(<#T##email: String##String#>)
//    }
    
    func changePassword(newPassword: String, nonce: String) async throws {
        try await supabase.auth.update(user: UserAttributes(password: newPassword, nonce: nonce))
        
    }
    
    func logout() async throws {
        try await supabase.auth.signOut()
        await MainActor.run {
            self.authToken = nil
        }
        persistProfileId(nil)
    }
}
