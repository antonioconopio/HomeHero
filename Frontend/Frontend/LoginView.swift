import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: AppSession
    @Environment(\.dismiss) private var dismiss

    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @FocusState private var focusedField: Field?

    private enum Field {
        case username
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
                                icon: "person.fill",
                                placeholder: "Username",
                                text: $username
                            )
                            .focused($focusedField, equals: .username)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .password }
                            
                            ModernSecureField(
                                icon: "lock.fill",
                                placeholder: "Password",
                                text: $password
                            )
                            .focused($focusedField, equals: .password)
                            .submitLabel(.go)
                            .onSubmit { attemptLogin() }
                            
                            if let errorMessage {
                                HStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundStyle(.red.opacity(0.90))
                                    Text(errorMessage)
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
                            Button(action: attemptLogin) {
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
                                
                                Button {
                                    dismiss()
                                } label: {
                                    Text("Create account")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.white)
                                }
                            }
                            .padding(.top, 8)
                            
                            Text("Temporary: **sudo** / **sudo**")
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
        .onAppear { focusedField = .username }
    }

    private func attemptLogin() {
        errorMessage = nil

        let ok = session.login(username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                               password: password)

        if !ok {
            errorMessage = "Invalid credentials. Try username \"sudo\" and password \"sudo\"."
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
            
            TextField(placeholder, text: $text)
                .font(.system(size: 17, design: .rounded))
                .foregroundStyle(.white)
                .tint(AppColor.powderBlue)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textContentType(.username)
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
            
            SecureField(placeholder, text: $text)
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
    NavigationStack {
        LoginView()
            .environmentObject(AppSession())
    }
}
