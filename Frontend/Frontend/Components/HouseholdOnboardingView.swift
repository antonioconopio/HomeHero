//
//  HouseholdOnboardingView.swift
//  Frontend
//
//  Full-screen onboarding view for users who need to create or join a household
//

import SwiftUI

struct HouseholdOnboardingView: View {
    @EnvironmentObject private var householdSession: HouseholdSession
    
    @State private var showCreateHousehold = false
    @State private var showJoinHousehold = false
    @State private var animateElements = false
    
    var body: some View {
        ZStack {
            AppColor.dropBackground.ignoresSafeArea()
            AnimatedBackgroundOrbs()
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Animated illustration
                illustrationSection
                
                // Welcome text
                welcomeSection
                
                // Action buttons
                actionButtons
                
                Spacer()
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .sheet(isPresented: $showCreateHousehold) {
            CreateHouseholdFlowSheet()
                .environmentObject(householdSession)
        }
        .sheet(isPresented: $showJoinHousehold) {
            JoinHouseholdPlaceholderSheet()
                .environmentObject(householdSession)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animateElements = true
            }
        }
    }
    
    // MARK: - Illustration Section
    
    private var illustrationSection: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .stroke(
                    RadialGradient(
                        colors: [AppColor.accentTeal.opacity(0.3), .clear],
                        center: .center,
                        startRadius: 40,
                        endRadius: 100
                    ),
                    lineWidth: 30
                )
                .frame(width: 180, height: 180)
                .blur(radius: 20)
                .scaleEffect(animateElements ? 1.1 : 0.9)
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animateElements)
            
            // Middle decorative ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [AppColor.accentTeal.opacity(0.2), AppColor.powderBlue.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .frame(width: 140, height: 140)
                .rotationEffect(.degrees(animateElements ? 360 : 0))
                .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: animateElements)
            
            // Inner decorative ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [AppColor.accentMint.opacity(0.3), AppColor.accentSky.opacity(0.15)],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    ),
                    lineWidth: 1.5
                )
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(animateElements ? -360 : 0))
                .animation(.linear(duration: 15).repeatForever(autoreverses: false), value: animateElements)
            
            // Main icon container
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AppColor.accentTeal.opacity(0.2), AppColor.accentSky.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [AppColor.accentTeal.opacity(0.6), AppColor.accentSky.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: AppColor.accentTeal.opacity(0.3), radius: 30, x: 0, y: 15)
                
                Image(systemName: "house.and.flag.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColor.accentTeal, AppColor.accentSky],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .scaleEffect(animateElements ? 1 : 0.8)
            .opacity(animateElements ? 1 : 0)
            
            // Floating particles
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .fill(
                        [AppColor.accentTeal, AppColor.accentSky, AppColor.accentMint, AppColor.powderBlue, AppColor.accentLavender][index].opacity(0.6)
                    )
                    .frame(width: CGFloat.random(in: 4...8), height: CGFloat.random(in: 4...8))
                    .offset(
                        x: CGFloat([-60, 70, -50, 65, -40][index]),
                        y: CGFloat([-70, -50, 60, 55, -30][index])
                    )
                    .offset(
                        y: animateElements ? CGFloat.random(in: -10...10) : 0
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 2...4))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                        value: animateElements
                    )
                    .blur(radius: 1)
            }
        }
        .frame(height: 200)
        .opacity(animateElements ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateElements)
    }
    
    // MARK: - Welcome Section
    
    private var welcomeSection: some View {
        VStack(spacing: 14) {
            Text("Welcome to HomeHero!")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppColor.textPrimary)
                .multilineTextAlignment(.center)
            
            Text("To get started, create a new household or join an existing one with a home code.")
                .font(.system(size: 16, design: .rounded))
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .opacity(animateElements ? 1 : 0)
        .offset(y: animateElements ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animateElements)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 14) {
            // Create household button
            Button {
                showCreateHousehold = true
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.15))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Create household")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                        Text("Start fresh with your roommates")
                            .font(.system(size: 13, design: .rounded))
                            .opacity(0.8)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .opacity(0.7)
                }
                .foregroundStyle(.white)
                .padding(18)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [AppColor.accentTeal, AppColor.accentSky],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(AppColor.shimmerGradient)
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: AppColor.accentTeal.opacity(0.4), radius: 20, x: 0, y: 10)
            }
            
            // Join household button
            Button {
                showJoinHousehold = true
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(AppColor.accentLavender.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppColor.accentLavender)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Join household")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppColor.textPrimary)
                        Text("Enter a home code to join")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(AppColor.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColor.textTertiary)
                }
                .padding(18)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(AppColor.surface)
                        
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [AppColor.accentLavender.opacity(0.4), AppColor.powderBlue.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    }
                )
                .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 8)
            }
        }
        .opacity(animateElements ? 1 : 0)
        .offset(y: animateElements ? 0 : 30)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateElements)
    }
}

#Preview {
    HouseholdOnboardingView()
        .environmentObject(HouseholdSession())
}
