import SwiftUI

struct HouseholdGateView<Content: View>: View {
    @EnvironmentObject private var householdSession: HouseholdSession

    let title: String
    let subtitle: String
    @ViewBuilder let content: () -> Content

    @State private var showCreateHousehold = false
    @State private var showJoinPlaceholder = false

    var body: some View {
        if householdSession.selectedHousehold != nil {
            content()
        } else {
            ZStack {
                AppColor.mintCream.ignoresSafeArea()
                VStack(spacing: 16) {
                    Image(systemName: "house.and.flag.fill")
                        .font(.system(size: 54))
                        .foregroundStyle(AppColor.oxfordNavy)

                    Text(title)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColor.oxfordNavy)

                    Text(subtitle)
                        .font(.system(size: 15, design: .rounded))
                        .foregroundStyle(AppColor.prussianBlue.opacity(0.70))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    VStack(spacing: 10) {
                        Button {
                            showCreateHousehold = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "plus.circle.fill")
                                Text("Create household")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                Spacer()
                            }
                            .foregroundStyle(.white)
                            .padding(16)
                            .background(
                                LinearGradient(
                                    colors: [AppColor.oxfordNavy, AppColor.regalNavy],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: AppColor.oxfordNavy.opacity(0.25), radius: 10, x: 0, y: 6)
                        }

                        Button {
                            showJoinPlaceholder = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "person.2.fill")
                                Text("Join household")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                Spacer()
                            }
                            .foregroundStyle(AppColor.oxfordNavy)
                            .padding(16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .padding(.top, 24)
            }
            .sheet(isPresented: $showCreateHousehold) {
                CreateHouseholdFlowSheet()
                    .environmentObject(householdSession)
            }
            .sheet(isPresented: $showJoinPlaceholder) {
                JoinHouseholdPlaceholderSheet()
                    .environmentObject(householdSession)
            }
        }
    }
}

