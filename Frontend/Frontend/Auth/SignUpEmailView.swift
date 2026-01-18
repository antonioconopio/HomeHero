//
//  SignUpEmailView.swift
//  HomeHero
//
//  Beautiful sign up page with dark aesthetic
//

import SwiftUI
internal import Combine

@MainActor
final class SignUpEmailViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var firstname = ""
    @Published var lastname = ""
    @Published var phone = ""
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            throw AppError.message("Please enter your email and password.")
        }
        guard !firstname.isEmpty else {
            throw AppError.message("Please enter your first name.")
        }
        
        try await AuthenticationManager.shared.createUser(
            email: email,
            password: password,
            firstname: firstname,
            lastname: lastname,
            phone: phone
        )
    }
}

struct SignUpEmailView: View {
    @Binding var showSignedInView: Bool
    @StateObject private var viewModel = SignUpEmailViewModel()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    @State private var animateElements = false

    private enum Field {
        case firstname
        case lastname
        case email
        case phone
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
                    VStack(spacing: 28) {
                        // Header
                        headerSection
                        
                        // Form sections
                        personalInfoSection
                        contactInfoSection
                        securitySection
                        
                        // Error message
                        if !viewModel.errorMessage.isEmpty {
                            errorCard
                        }
                        
                        // Create account button
                        createAccountButton
                        
                        // Sign in link
                        signInLink
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.dark)
        .onAppear {
            focusedField = .firstname
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
                            colors: [AppColor.accentLavender.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)
                
                GradientIconBadge(
                    icon: "person.badge.plus",
                    colors: [AppColor.accentLavender, AppColor.powderBlue],
                    size: 72,
                    iconSize: 32
                )
            }
            
            VStack(spacing: 8) {
                Text("Join HomeHero")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                
                Text("Create your account in seconds")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .padding(.top, 16)
        .opacity(animateElements ? 1 : 0)
        .offset(y: animateElements ? 0 : 20)
    }
    
    // MARK: - Personal Info Section
    
    private var personalInfoSection: some View {
        GlassCard(accentColor: AppColor.accentLavender) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    GradientIconBadge(
                        icon: "person.fill",
                        colors: [AppColor.accentLavender, AppColor.powderBlue],
                        size: 36,
                        iconSize: 16
                    )
                    
                    Text("Personal Info")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColor.textPrimary)
                }
                
                HStack(spacing: 12) {
                    AuthTextField(
                        icon: "person.fill",
                        placeholder: "First name",
                        text: $viewModel.firstname,
                        colors: [AppColor.accentLavender, AppColor.powderBlue]
                    )
                    .focused($focusedField, equals: .firstname)
                    .textContentType(.givenName)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .lastname }
                    
                    AuthTextField(
                        icon: "person.fill",
                        placeholder: "Last name",
                        text: $viewModel.lastname,
                        colors: [AppColor.accentLavender, AppColor.powderBlue]
                    )
                    .focused($focusedField, equals: .lastname)
                    .textContentType(.familyName)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .email }
                }
            }
            .padding(18)
        }
        .opacity(animateElements ? 1 : 0)
        .offset(y: animateElements ? 0 : 30)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15), value: animateElements)
    }
    
    // MARK: - Contact Info Section
    
    private var contactInfoSection: some View {
        GlassCard(accentColor: AppColor.accentTeal) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    GradientIconBadge(
                        icon: "envelope.fill",
                        colors: [AppColor.accentTeal, AppColor.accentSky],
                        size: 36,
                        iconSize: 16
                    )
                    
                    Text("Contact")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColor.textPrimary)
                }
                
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
                .onSubmit { focusedField = .phone }
                
                AuthTextField(
                    icon: "phone.fill",
                    placeholder: "Phone number (optional)",
                    text: $viewModel.phone,
                    colors: [AppColor.accentMint, AppColor.accentTeal]
                )
                .focused($focusedField, equals: .phone)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
            }
            .padding(18)
        }
        .opacity(animateElements ? 1 : 0)
        .offset(y: animateElements ? 0 : 30)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateElements)
    }
    
    // MARK: - Security Section
    
    private var securitySection: some View {
        GlassCard(accentColor: AppColor.accentAmber) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    GradientIconBadge(
                        icon: "lock.fill",
                        colors: [AppColor.accentAmber, AppColor.accentCoral],
                        size: 36,
                        iconSize: 16
                    )
                    
                    Text("Security")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColor.textPrimary)
                }
                
                AuthSecureField(
                    icon: "lock.fill",
                    placeholder: "Create a password",
                    text: $viewModel.password,
                    colors: [AppColor.accentAmber, AppColor.accentCoral]
                )
                .focused($focusedField, equals: .password)
                .textContentType(.newPassword)
                .submitLabel(.done)
                .onSubmit { attemptSignUp() }
                
                // Password hints
                HStack(spacing: 16) {
                    PasswordHint(text: "8+ characters", isMet: viewModel.password.count >= 8)
                    PasswordHint(text: "Has number", isMet: viewModel.password.contains(where: { $0.isNumber }))
                }
            }
            .padding(18)
        }
        .opacity(animateElements ? 1 : 0)
        .offset(y: animateElements ? 0 : 30)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.25), value: animateElements)
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
    
    // MARK: - Create Account Button
    
    private var createAccountButton: some View {
        Button(action: attemptSignUp) {
            HStack(spacing: 14) {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 22, weight: .semibold))
                    Text("Create account")
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
                                colors: [AppColor.accentLavender, AppColor.powderBlue],
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
            .shadow(color: AppColor.accentLavender.opacity(0.4), radius: 20, x: 0, y: 10)
        }
        .disabled(viewModel.isLoading)
        .opacity(animateElements ? 1 : 0)
        .offset(y: animateElements ? 0 : 30)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: animateElements)
    }
    
    // MARK: - Sign In Link
    
    private var signInLink: some View {
        HStack(spacing: 8) {
            Text("Already have an account?")
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(AppColor.textSecondary)
            
            Button {
                dismiss()
            } label: {
                Text("Log in")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColor.accentLavender)
            }
        }
        .opacity(animateElements ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.35), value: animateElements)
    }
    
    // MARK: - Actions
    
    private func attemptSignUp() {
        viewModel.isLoading = true
        Task {
            do {
                viewModel.errorMessage = ""
                try await viewModel.signUp()
                showSignedInView = false
            } catch {
                viewModel.errorMessage = error.localizedDescription
            }
            viewModel.isLoading = false
        }
    }
}

// MARK: - Password Hint

struct PasswordHint: View {
    let text: String
    let isMet: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isMet ? AppColor.accentMint : AppColor.textTertiary)
            
            Text(text)
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(isMet ? AppColor.textSecondary : AppColor.textTertiary)
        }
    }
}

#Preview {
    NavigationView {
        SignUpEmailView(showSignedInView: .constant(true))
    }
}
