import SwiftUI

struct CreateAccountView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var agreed: Bool = false
    @State private var showComingSoon: Bool = false
    @FocusState private var focusedField: Field?

    private enum Field {
        case fullName
        case email
        case password
        case confirmPassword
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
                            ModernInputField(
                                icon: "person.fill",
                                placeholder: "Full name",
                                text: $fullName,
                                contentType: .name,
                                keyboard: .default
                            )
                            .focused($focusedField, equals: .fullName)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .email }
                            
                            ModernInputField(
                                icon: "envelope.fill",
                                placeholder: "Email",
                                text: $email,
                                contentType: .emailAddress,
                                keyboard: .emailAddress
                            )
                            .focused($focusedField, equals: .email)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .password }
                            
                            ModernPasswordField(
                                icon: "lock.fill",
                                placeholder: "Password",
                                text: $password,
                                contentType: .newPassword
                            )
                            .focused($focusedField, equals: .password)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .confirmPassword }
                            
                            ModernPasswordField(
                                icon: "lock.rotation",
                                placeholder: "Confirm password",
                                text: $confirmPassword,
                                contentType: .newPassword
                            )
                            .focused($focusedField, equals: .confirmPassword)
                            .submitLabel(.done)
                            .onSubmit { attemptCreate() }
                            
                            if let validationMessage {
                                HStack(spacing: 12) {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundStyle(AppColor.powderBlue)
                                    Text(validationMessage)
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.85))
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer(minLength: 0)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(.white.opacity(0.08))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .stroke(AppColor.powderBlue.opacity(0.30), lineWidth: 1)
                                        )
                                )
                            }
                            
                            HStack(spacing: 12) {
                                Toggle(isOn: $agreed) {
                                    EmptyView()
                                }
                                .labelsHidden()
                                .tint(AppColor.powderBlue)
                                
                                Text("I agree to the Terms & Privacy Policy")
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.80))
                                
                                Spacer()
                            }
                            .padding(.top, 4)
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            Button(action: attemptCreate) {
                                HStack(spacing: 12) {
                                    Text("Create account")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundStyle(canSubmit ? AppColor.oxfordNavy : .white.opacity(0.50))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(canSubmit ? .white : .white.opacity(0.20))
                                )
                                .shadow(color: canSubmit ? .white.opacity(0.25) : .clear, radius: 20, x: 0, y: 10)
                            }
                            .disabled(!canSubmit)
                            
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
                            
                            Text("UI only — auth coming soon")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundStyle(.white.opacity(0.50))
                                .padding(.top, 8)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear { focusedField = .fullName }
        .alert("Coming soon", isPresented: $showComingSoon) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Account creation isn't wired up yet — this is the new UI shell.")
        }
    }

    private var trimmedName: String {
        fullName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var emailLooksValid: Bool {
        trimmedEmail.contains("@") && trimmedEmail.contains(".") && !trimmedEmail.contains(" ")
    }

    private var passwordsMatch: Bool {
        !password.isEmpty && password == confirmPassword
    }

    private var passwordLooksValid: Bool {
        password.count >= 6
    }

    private var canSubmit: Bool {
        !trimmedName.isEmpty && emailLooksValid && passwordLooksValid && passwordsMatch && agreed
    }

    private var validationMessage: String? {
        if trimmedName.isEmpty || trimmedEmail.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            return nil
        }
        if !emailLooksValid {
            return "Please enter a valid email address."
        }
        if !passwordLooksValid {
            return "Password should be at least 6 characters."
        }
        if !passwordsMatch {
            return "Passwords don't match."
        }
        if !agreed {
            return "Please agree to the Terms & Privacy Policy to continue."
        }
        return nil
    }

    private func attemptCreate() {
        guard canSubmit else { return }
        showComingSoon = true
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
            
            TextField(placeholder, text: $text)
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
            
            SecureField(placeholder, text: $text)
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
    NavigationStack {
        CreateAccountView()
    }
}
