import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var session: AppSession

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [AppColor.oxfordNavy, AppColor.regalNavy],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 14) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundStyle(.white)

                    Text("You’re logged in.")
                        .font(.title2.bold())
                        .foregroundStyle(.white)

                    Text("This is a placeholder Home screen until the real app pages are built.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.80))

                    Button("Log Out") {
                        session.logout()
                    }
                    .buttonStyle(.bordered)
                    .tint(.white)
                    .padding(.top, 6)
                }
                .padding()
            }
            .navigationTitle("HomeHero")
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppSession())
}

