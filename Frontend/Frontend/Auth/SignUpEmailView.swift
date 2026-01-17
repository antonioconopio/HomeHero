//
//  SignInEmailView.swift
//  HomeHero
//
//  Created by Antonio conopio on 2025-10-25.
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
    
    func signUp() async throws{
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        try await AuthenticationManager.shared.createUser(
            email: email,
            password: password,
            firstname: firstname,
            lastname: lastname,
            phone: phone)

    }
}

struct SignUpEmailView: View {
    
    @Binding var showSignedInView: Bool
    @StateObject private var viewModel = SignUpEmailViewModel()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?

    private enum Field {
        case firstname
        case lastname
        case email
        case phone
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
                .fill(AppColor.regalNavy.opacity(0.20))
                .frame(width: 320, height: 320)
                .blur(radius: 55)
                .offset(x: 150, y: -260)
            
            Circle()
                .fill(AppColor.powderBlue.opacity(0.25))
                .frame(width: 360, height: 360)
                .blur(radius: 65)
                .offset(x: -160, y: 320)

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
                            Text("Join HomeHero")
                                .font(.system(size: 38, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            
                            Text("Create your account in seconds")
                                .font(.system(size: 17, weight: .regular, design: .rounded))
                                .foregroundStyle(.white.opacity(0.70))
                        }
                        .padding(.top, 24)
                        
                        VStack(spacing: 16) {
                            HStack(spacing: 12) {
                                ModernInputField(
                                    icon: "person.fill",
                                    placeholder: "First name",
                                    text: $viewModel.firstname,
                                    contentType: .givenName,
                                    keyboard: .default
                                )
                                .focused($focusedField, equals: .firstname)
                                .submitLabel(.next)
                                .onSubmit { focusedField = .lastname }
                                
                                ModernInputField(
                                    icon: "person.fill",
                                    placeholder: "Last name",
                                    text: $viewModel.lastname,
                                    contentType: .familyName,
                                    keyboard: .default
                                )
                                .focused($focusedField, equals: .lastname)
                                .submitLabel(.next)
                                .onSubmit { focusedField = .email }
                            }
                            
                            ModernInputField(
                                icon: "envelope.fill",
                                placeholder: "Email",
                                text: $viewModel.email,
                                contentType: .emailAddress,
                                keyboard: .emailAddress
                            )
                            .focused($focusedField, equals: .email)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .phone }
                            
                            ModernInputField(
                                icon: "phone.fill",
                                placeholder: "Phone number",
                                text: $viewModel.phone,
                                contentType: .telephoneNumber,
                                keyboard: .phonePad
                            )
                            .focused($focusedField, equals: .phone)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .password }
                            
                            ModernPasswordField(
                                icon: "lock.fill",
                                placeholder: "Password",
                                text: $viewModel.password,
                                contentType: .newPassword
                            )
                            .focused($focusedField, equals: .password)
                            .submitLabel(.done)
                            .onSubmit { attemptSignUp() }
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            Button(action: attemptSignUp) {
                                HStack(spacing: 12) {
                                    Text("Create account")
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
                                Text("Already have an account?")
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.70))
                                
                                Button {
                                    dismiss()
                                } label: {
                                    Text("Log in")
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
        .onAppear { focusedField = .firstname }
    }
    
    private func attemptSignUp() {
        Task{
            do{
                try await viewModel.signUp()
                print("Successfully signed up")
                showSignedInView = false
            } catch{
                print(error)
            }
        }
    }
}

struct ModernInputField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    let contentType: UITextContentType?
    let keyboard: UIKeyboardType
    
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
                .textInputAutocapitalization(contentType == .emailAddress ? .never : .words)
                .autocorrectionDisabled()
                .keyboardType(keyboard)
                .textContentType(contentType)
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

struct ModernPasswordField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    let contentType: UITextContentType?
    
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
                .textContentType(contentType)
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
        SignUpEmailView(showSignedInView: .constant(true))
    }
}
