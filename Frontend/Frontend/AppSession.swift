import Foundation

@MainActor
final class AppSession: ObservableObject {
    @Published var isLoggedIn: Bool = false

    /// Temporary credentials until real auth is implemented.
    private let tempUsername = "sudo"
    private let tempPassword = "sudo"

    func login(username: String, password: String) -> Bool {
        let ok = (username == tempUsername && password == tempPassword)
        if ok {
            isLoggedIn = true
        }
        return ok
    }

    func logout() {
        isLoggedIn = false
    }
}

