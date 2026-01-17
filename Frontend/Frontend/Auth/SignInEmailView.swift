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
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case email
        case password
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColor.oxfordNavy, AppColor.regalNavy],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Circle()
                .fill(AppColor.powderBlue.opacity(0.20))
                .frame(width: 350, height: 350)
                .blur(radius: 60)
                .offset(x: -140, y: -220)
            
            Circle()
                .fill(AppColor.regalNavy.opacity(0.25))
                .frame(width: 280, height: 280)
                .blur(radius: 50)
                .offset(x: 160, y: 300)

            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                ScrollView {
                    VStack(spacing: 32) {
                        VStack(spacing: 16) {
                            Text("Welcome Back")
                                .font(.system(size: 38, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            
                            Text("Sign in to continue")
                                .font(.system(size: 17, weight: .regular, design: .rounded))
                                .foregroundStyle(.white.opacity(0.70))
                        }
                        .padding(.top, 32)
                        
                        VStack(spacing: 20) {
                            ModernTextField(
                                icon: "envelope.fill",
                                placeholder: "Email",
                                text: $viewModel.email
                            )
                            .focused($focusedField, equals: .email)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .password }
                            
                            ModernSecureField(
                                icon: "lock.fill",
                                placeholder: "Password",
                                text: $viewModel.password
                            )
                            .focused($focusedField, equals: .password)
                            .submitLabel(.go)
                            .onSubmit { attemptSignIn() }
                            
                            if !viewModel.errorMessage.isEmpty {
                                HStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundStyle(.red.opacity(0.90))
                                    Text(viewModel.errorMessage)
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.90))
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer(minLength: 0)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(.red.opacity(0.15))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .stroke(.red.opacity(0.30), lineWidth: 1)
                                        )
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            Button(action: attemptSignIn) {
                                HStack(spacing: 12) {
                                    Text("Sign in")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundStyle(AppColor.oxfordNavy)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(.white)
                                )
                                .shadow(color: .white.opacity(0.25), radius: 20, x: 0, y: 10)
                            }
                            
                            HStack(spacing: 8) {
                                Text("New to HomeHero?")
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.70))
                                
                                NavigationLink {
                                    SignUpEmailView(showSignedInView: $showSignedInView)
                                } label: {
                                    Text("Create account")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.white)
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear { focusedField = .email }
    }
    
    private func attemptSignIn() {
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
    }
}

struct ModernTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.white.opacity(0.60))
                .frame(width: 24)
            
            TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(.white.opacity(0.55)))
                .font(.system(size: 17, design: .rounded))
                .foregroundStyle(.white)
                .tint(AppColor.powderBlue)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.white.opacity(0.15), lineWidth: 1)
                )
        )
    }
}

struct ModernSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.white.opacity(0.60))
                .frame(width: 24)
            
            SecureField("", text: $text, prompt: Text(placeholder).foregroundStyle(.white.opacity(0.55)))
                .font(.system(size: 17, design: .rounded))
                .foregroundStyle(.white)
                .tint(AppColor.powderBlue)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textContentType(.password)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.white.opacity(0.15), lineWidth: 1)
                )
        )
    }
}

#Preview {
    NavigationView{
        SignInEmailView(showSignedInView: .constant(true))
    }
}
