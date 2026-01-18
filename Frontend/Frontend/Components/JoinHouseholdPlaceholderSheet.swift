import SwiftUI

struct JoinHouseholdPlaceholderSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var householdSession: HouseholdSession

    @State private var homeCode = ""
    @State private var isJoining = false
    @FocusState private var isCodeFieldFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.dropBackground.ignoresSafeArea()
                AnimatedBackgroundOrbs()
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    // Header illustration
                    headerSection
                    
                    // Code input card
                    codeInputCard
                    
                    // Error message
                    if let msg = householdSession.errorMessage, !msg.isEmpty {
                        errorCard(msg)
                    }
                    
                    // Join button
                    joinButton
                    
                    Spacer()
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("Join Household")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColor.dropBackground.opacity(0.8), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isCodeFieldFocused = true
                }
            }
        }
    }
    
    private var canJoin: Bool {
        homeCode.count == 6
    }
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            ZStack {
                // Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColor.accentLavender.opacity(0.35), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 130, height: 130)
                    .blur(radius: 25)
                
                GradientIconBadge(
                    icon: "person.badge.key.fill",
                    colors: [AppColor.accentLavender, AppColor.powderBlue],
                    size: 80,
                    iconSize: 36
                )
            }
            
            VStack(spacing: 10) {
                Text("Enter Home Code")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                
                Text("Ask a roommate for the 6-digit code to join their household")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
        }
    }
    
    private var codeInputCard: some View {
        GlassCard(accentColor: AppColor.accentLavender) {
            VStack(spacing: 16) {
                // Code display
                HStack(spacing: 10) {
                    ForEach(0..<6, id: \.self) { index in
                        codeDigitBox(at: index)
                    }
                }
                
                // Hidden text field for input
                TextField("", text: Binding(
                    get: { homeCode },
                    set: { newValue in
                        let digits = newValue.filter { $0.isNumber }
                        homeCode = String(digits.prefix(6))
                    }
                ))
                .keyboardType(.numberPad)
                .focused($isCodeFieldFocused)
                .opacity(0)
                .frame(height: 1)
                
                // Tap hint
                Text("Tap to enter code")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(AppColor.textTertiary)
            }
            .padding(24)
            .contentShape(Rectangle())
            .onTapGesture {
                isCodeFieldFocused = true
            }
        }
    }
    
    private func codeDigitBox(at index: Int) -> some View {
        let digit = index < homeCode.count ? String(homeCode[homeCode.index(homeCode.startIndex, offsetBy: index)]) : ""
        let isFilled = !digit.isEmpty
        let isCurrentPosition = index == homeCode.count && homeCode.count < 6
        
        return ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppColor.surface2)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(
                            isCurrentPosition
                                ? AppColor.accentLavender
                                : isFilled
                                    ? AppColor.accentLavender.opacity(0.5)
                                    : AppColor.textTertiary.opacity(0.3),
                            lineWidth: isCurrentPosition ? 2 : 1
                        )
                )
                .frame(width: 48, height: 60)
            
            if isFilled {
                Text(digit)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColor.accentLavender, AppColor.powderBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            } else if isCurrentPosition {
                RoundedRectangle(cornerRadius: 2)
                    .fill(AppColor.accentLavender)
                    .frame(width: 2, height: 24)
                    .opacity(isCodeFieldFocused ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isCodeFieldFocused)
            }
        }
        .scaleEffect(isFilled ? 1.0 : 0.95)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isFilled)
    }
    
    private func errorCard(_ message: String) -> some View {
        GlassCard(accentColor: AppColor.accentCoral) {
            HStack(spacing: 12) {
                GradientIconBadge(
                    icon: "exclamationmark.triangle.fill",
                    colors: [AppColor.accentCoral, AppColor.accentAmber],
                    size: 40,
                    iconSize: 18
                )
                
                Text(message)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(2)
                
                Spacer()
            }
            .padding(16)
        }
    }
    
    private var joinButton: some View {
        Button {
            Task { await join() }
        } label: {
            HStack(spacing: 14) {
                if isJoining {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                    Text("Join Household")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
                Spacer()
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            canJoin
                                ? LinearGradient(colors: [AppColor.accentLavender, AppColor.powderBlue], startPoint: .leading, endPoint: .trailing)
                                : LinearGradient(colors: [AppColor.textTertiary, AppColor.textTertiary], startPoint: .leading, endPoint: .trailing)
                        )
                    
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppColor.shimmerGradient)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: canJoin ? AppColor.accentLavender.opacity(0.4) : .clear, radius: 16, x: 0, y: 8)
        }
        .disabled(isJoining || !canJoin)
        .opacity(canJoin ? 1 : 0.6)
    }

    @MainActor
    private func join() async {
        isJoining = true
        defer { isJoining = false }
        let result = await householdSession.joinHousehold(homeCode: homeCode)
        if result != nil {
            dismiss()
        }
    }
}
