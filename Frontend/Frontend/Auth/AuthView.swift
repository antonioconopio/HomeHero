//
//  AuthView.swift
//  HomeHero
//
//  Beautiful landing page with dark aesthetic
//

import SwiftUI

struct AuthView: View {
    @Binding var showSignedInView: Bool
    @State private var animateElements = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AppColor.dropBackground.ignoresSafeArea()
                
                // Animated orbs
                AuthBackgroundOrbs()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Hero section
                    heroSection
                    
                    Spacer()
                    
                    // Features preview
                    featuresSection
                    
                    Spacer()
                    
                    // Action buttons
                    actionButtons
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animateElements = true
            }
        }
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        VStack(spacing: 24) {
            // Animated logo
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColor.accentTeal.opacity(0.4), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .blur(radius: 30)
                    .scaleEffect(animateElements ? 1.1 : 0.9)
                    .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animateElements)
                
                // Rotating ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [AppColor.accentTeal.opacity(0.3), AppColor.accentSky.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 130, height: 130)
                    .rotationEffect(.degrees(animateElements ? 360 : 0))
                    .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: animateElements)
                
                // Icon container
                ZStack {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [AppColor.accentTeal.opacity(0.25), AppColor.accentSky.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [AppColor.accentTeal.opacity(0.6), AppColor.accentSky.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: AppColor.accentTeal.opacity(0.4), radius: 30, x: 0, y: 15)
                    
                    Image(systemName: "house.fill")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColor.accentTeal, AppColor.accentSky],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .scaleEffect(animateElements ? 1 : 0.8)
            .opacity(animateElements ? 1 : 0)
            
            // Title and tagline
            VStack(spacing: 14) {
                Text("HomeHero")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                
                Text("Taking the stress out of shared living")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(AppColor.surface)
                            .overlay(
                                Capsule()
                                    .stroke(
                                        LinearGradient(
                                            colors: [AppColor.accentTeal.opacity(0.3), AppColor.accentSky.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    )
            }
            .opacity(animateElements ? 1 : 0)
            .offset(y: animateElements ? 0 : 20)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animateElements)
        }
    }
    
    // MARK: - Features Section
    
    private var featuresSection: some View {
        HStack(spacing: 16) {
            FeaturePill(icon: "checklist", title: "Tasks", colors: [AppColor.accentAmber, AppColor.accentCoral])
            FeaturePill(icon: "dollarsign.circle.fill", title: "Expenses", colors: [AppColor.accentMint, AppColor.accentTeal])
            FeaturePill(icon: "person.2.fill", title: "Roommates", colors: [AppColor.accentLavender, AppColor.powderBlue])
        }
        .opacity(animateElements ? 1 : 0)
        .offset(y: animateElements ? 0 : 30)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateElements)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 14) {
            // Log in button
            NavigationLink {
                SignInEmailView(showSignedInView: $showSignedInView)
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.15))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    
                    Text("Log in")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    
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
            
            // Create account button
            NavigationLink {
                SignUpEmailView(showSignedInView: $showSignedInView)
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(AppColor.accentLavender.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppColor.accentLavender)
                    }
                    
                    Text("Create account")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColor.textPrimary)
                    
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
                .shadow(color: .black.opacity(0.3), radius: 16, x: 0, y: 8)
            }
        }
        .opacity(animateElements ? 1 : 0)
        .offset(y: animateElements ? 0 : 40)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: animateElements)
    }
}

// MARK: - Feature Pill

struct FeaturePill: View {
    let icon: String
    let title: String
    let colors: [Color]
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: colors.map { $0.opacity(0.2) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: colors.map { $0.opacity(0.5) },
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }
            
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppColor.textTertiary.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Auth Background Orbs

struct AuthBackgroundOrbs: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Top-right teal orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppColor.accentTeal.opacity(0.25), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .offset(x: 140, y: -250)
                .offset(x: animate ? 30 : -30, y: animate ? -20 : 20)
            
            // Bottom-left lavender orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppColor.accentLavender.opacity(0.2), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: -160, y: 350)
                .offset(x: animate ? -25 : 25, y: animate ? 20 : -20)
            
            // Center sky orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppColor.accentSky.opacity(0.15), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)
                .offset(x: 60, y: 100)
                .offset(x: animate ? 20 : -20, y: animate ? -15 : 15)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

#Preview {
    AuthView(showSignedInView: .constant(true))
}
