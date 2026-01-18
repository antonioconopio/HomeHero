//
//  SignInEmailView.swift
//  HomeHero
//
//  Beautiful sign in page with dark aesthetic
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
    @Published var isLoading = false
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            throw AppError.message("Please enter your email and password.")
        }
        
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
}

struct SignInEmailView: View {
    @Binding var showSignedInView: Bool
    @StateObject private var viewModel = SignInEmailViewModel()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    @State private var animateElements = false
    
    private enum Field {
        case email
        case password
    }
    
    var body: some View {
        ZStack {
            // Background
            AppColor.dropBackground.ignoresSafeArea()
            AuthBackgroundOrbs()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Back button
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(AppColor.surface)
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Circle()
                                        .stroke(AppColor.textTertiary.opacity(0.3), lineWidth: 1)
                                )
                            
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(AppColor.textPrimary)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Header
                        headerSection
                        
                        // Form
                        formSection
                        
                        // Error message
                        if !viewModel.errorMessage.isEmpty {
                            errorCard
                        }
                        
                        // Sign in button
                        signInButton
                        
                        // Create account link
                        createAccountLink
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.dark)
        .onAppear {
            focusedField = .email
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateElements = true
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColor.accentTeal.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)
                
                GradientIconBadge(
                    icon: "person.fill.checkmark",
                    colors: [AppColor.accentTeal, AppColor.accentSky],
                    size: 72,
                    iconSize: 32
                )
            }
            
            VStack(spacing: 8) {
                Text("Welcome Back")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                
                Text("Sign in to continue")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .padding(.top, 24)
        .opacity(animateElements ? 1 : 0)
        .offset(y: animateElements ? 0 : 20)
    }
    
    // MARK: - Form Section
    
    private var formSection: some View {
        GlassCard(accentColor: AppColor.accentTeal) {
            VStack(spacing: 18) {
                // Email field
                AuthTextField(
                    icon: "envelope.fill",
                    placeholder: "Email address",
                    text: $viewModel.email,
                    colors: [AppColor.accentTeal, AppColor.accentSky]
                )
                .focused($focusedField, equals: .email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .submitLabel(.next)
                .onSubmit { focusedField = .password }
                
                // Password field
                AuthSecureField(
                    icon: "lock.fill",
                    placeholder: "Password",
                    text: $viewModel.password,
                    colors: [AppColor.accentLavender, AppColor.powderBlue]
                )
                .focused($focusedField, equals: .password)
                .textContentType(.password)
                .submitLabel(.go)
                .onSubmit { attemptSignIn() }
            }
            .padding(20)
        }
        .opacity(animateElements ? 1 : 0)
        .offset(y: animateElements ? 0 : 30)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15), value: animateElements)
    }
    
    // MARK: - Error Card
    
    private var errorCard: some View {
        GlassCard(accentColor: AppColor.accentCoral) {
            HStack(spacing: 14) {
                GradientIconBadge(
                    icon: "exclamationmark.triangle.fill",
                    colors: [AppColor.accentCoral, AppColor.accentAmber],
                    size: 44,
                    iconSize: 20
                )
                
                Text(viewModel.errorMessage)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(AppColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer(minLength: 0)
            }
            .padding(16)
        }
    }
    
    // MARK: - Sign In Button
    
    private var signInButton: some View {
        Button(action: attemptSignIn) {
            HStack(spacing: 14) {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                    Text("Sign in")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                }
                Spacer()
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 22)
            .padding(.vertical, 20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [AppColor.accentTeal, AppColor.accentSky],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppColor.shimmerGradient)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.white.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: AppColor.accentTeal.opacity(0.4), radius: 20, x: 0, y: 10)
        }
        .disabled(viewModel.isLoading)
        .opacity(animateElements ? 1 : 0)
        .offset(y: animateElements ? 0 : 30)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateElements)
    }
    
    // MARK: - Create Account Link
    
    private var createAccountLink: some View {
        HStack(spacing: 8) {
            Text("New to HomeHero?")
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(AppColor.textSecondary)
            
            NavigationLink {
                SignUpEmailView(showSignedInView: $showSignedInView)
            } label: {
                Text("Create account")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColor.accentTeal)
            }
        }
        .opacity(animateElements ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.25), value: animateElements)
    }
    
    // MARK: - Actions
    
    private func attemptSignIn() {
        viewModel.isLoading = true
        Task {
            do {
                viewModel.errorMessage = ""
                try await viewModel.signIn()
                showSignedInView = false
            } catch {
                viewModel.errorMessage = error.localizedDescription
            }
            viewModel.isLoading = false
        }
    }
}

// MARK: - Auth Text Field

struct AuthTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var colors: [Color] = [AppColor.accentTeal, AppColor.accentSky]
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: colors.map { $0.opacity(0.15) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }
            
            TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(AppColor.textTertiary))
                .font(.system(size: 16, design: .rounded))
                .foregroundStyle(AppColor.textPrimary)
                .tint(colors[0])
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppColor.surface2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [colors[0].opacity(0.3), colors[1].opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Auth Secure Field

struct AuthSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var colors: [Color] = [AppColor.accentLavender, AppColor.powderBlue]
    @State private var isSecure = true
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: colors.map { $0.opacity(0.15) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }
            
            if isSecure {
                SecureField("", text: $text, prompt: Text(placeholder).foregroundStyle(AppColor.textTertiary))
                    .font(.system(size: 16, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                    .tint(colors[0])
            } else {
                TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(AppColor.textTertiary))
                    .font(.system(size: 16, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                    .tint(colors[0])
            }
            
            Button {
                isSecure.toggle()
            } label: {
                Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppColor.textTertiary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppColor.surface2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [colors[0].opacity(0.3), colors[1].opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    NavigationView {
        SignInEmailView(showSignedInView: .constant(true))
    }
}
