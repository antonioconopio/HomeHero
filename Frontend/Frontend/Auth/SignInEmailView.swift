//
//  SignInEmailView.swift
//  HomeHero
//
//  Created by Antonio conopio on 2025-10-25.
//

import SwiftUI
internal import Combine

struct AppError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
    static func message(_ text: String) -> AppError { AppError(message: text) }
}

@MainActor
final class SignInEmailViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            throw AppError.message("No email or password found.")
        }
        
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
}

struct SignInEmailView: View {
    
    @Binding var showSignedInView: Bool
    @StateObject private var viewModel = SignInEmailViewModel()
    
    var body: some View {
        VStack{
            Spacer()
            
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .transition(.opacity)
            }
            
            TextField("Email...", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
            
            SecureField("Password...", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
            
            Button(action: {
                Task{
                    do{
                        viewModel.errorMessage = ""
                        try await viewModel.signIn()
                        showSignedInView = false
                    } catch {
                        viewModel.errorMessage = error.localizedDescription
                        print(error.localizedDescription)
                    }
                }
            }) {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 2)
                    )
                    .cornerRadius(10)
            }
            
            NavigationLink{
                SignUpEmailView(showSignedInView: $showSignedInView)
            } label: {
                Text("Don't have an account? Sign Up!")
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sign In")
    }
}

#Preview {
    NavigationView{
        SignInEmailView(showSignedInView: .constant(true))
    }
}
