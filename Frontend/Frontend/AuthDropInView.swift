import SwiftUI

struct AuthDropInView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [AppColor.oxfordNavy, AppColor.regalNavy],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                Circle()
                    .fill(AppColor.regalNavy.opacity(0.18))
                    .frame(width: 260, height: 260)
                    .blur(radius: 30)
                    .offset(x: 140, y: -180)

                Circle()
                    .fill(AppColor.powderBlue.opacity(0.30))
                    .frame(width: 280, height: 280)
                    .blur(radius: 26)
                    .offset(x: -160, y: 220)

                VStack(spacing: 0) {
                    // Upper hero
                    VStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .fill(.white.opacity(0.10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                                        .stroke(.white.opacity(0.16), lineWidth: 1)
                                )
                            Image(systemName: "house.fill")
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        .frame(width: 68, height: 68)

                        Text("HomeHero")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Taking the stress out of shared living.")
                            .font(.system(size: 19, weight: .medium, design: .rounded))
                            .kerning(0.5)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, AppColor.powderBlue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .padding(.horizontal, 22)
                            .padding(.vertical, 12)
                            .background(
                                ZStack {
                                    Capsule()
                                        .fill(.white.opacity(0.08))
                                        .blur(radius: 0.5)
                                    
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [.white.opacity(0.12), .white.opacity(0.06)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                }
                            )
                            .overlay(
                                Capsule()
                                    .stroke(
                                        LinearGradient(
                                            colors: [.white.opacity(0.25), .white.opacity(0.10)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(color: AppColor.powderBlue.opacity(0.30), radius: 20, x: 0, y: 8)
                            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                    }
                    .padding(.top, 56)
                    .padding(.horizontal)
                    .frame(maxWidth: 520)

                    Spacer(minLength: 16)

                    // Bottom actions
                    VStack(spacing: 12) {
                        NavigationLink {
                            LoginView()
                        } label: {
                            Text("Log in")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.white)
                        .foregroundStyle(AppColor.oxfordNavy)

                        NavigationLink {
                            CreateAccountView()
                        } label: {
                            Text("Create account")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.bordered)
                        .tint(.white.opacity(0.95))
                        .foregroundStyle(.white)
                    }
                    .padding(18)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(.white.opacity(0.14), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.22), radius: 22, x: 0, y: 10)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .frame(maxWidth: 520)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    AuthDropInView()
        .environmentObject(AppSession())
}

