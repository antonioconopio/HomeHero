//
//  HomePageView.swift
//  HomeHero
//
//  Beautiful home dashboard with animated cards
//

import SwiftUI

struct HomePageView: View {
    @EnvironmentObject private var householdSession: HouseholdSession
    @State private var animateCards = false

    var body: some View {
        NavigationStack {
            HouseholdGateView(
                title: "Join or create a household",
                subtitle: "To start using HomeHero, join a household or create one and invite your roommates."
            ) {
                ZStack {
                    // Background
                    AppColor.dropBackground.ignoresSafeArea()
                    AnimatedBackgroundOrbs()
                        .ignoresSafeArea()
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            // Hero Section
                            heroSection
                            
                            // Quick Stats
                            quickStatsSection
                            
                            // Dashboard Cards
                            dashboardCardsSection
                            
                            // Activity Feed
                            activitySection
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColor.dropBackground.opacity(0.8), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateCards = true
            }
        }
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        VStack(spacing: 16) {
            ZStack {
                // Glow behind icon
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColor.accentTeal.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)
                
                // Icon container
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [AppColor.accentTeal.opacity(0.2), AppColor.accentSky.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [AppColor.accentTeal.opacity(0.5), AppColor.accentSky.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .frame(width: 72, height: 72)
                    
                    Image(systemName: "house.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColor.accentTeal, AppColor.accentSky],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            
            VStack(spacing: 8) {
                Text(householdSession.selectedHousehold?.name ?? "Home")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                
                Text("Your shared living dashboard")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .padding(.horizontal)
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 20)
    }
    
    // MARK: - Quick Stats Section
    
    private var quickStatsSection: some View {
        HStack(spacing: 12) {
            QuickStatCard(
                value: "3",
                label: "Tasks Due",
                icon: "checklist",
                colors: [AppColor.accentAmber, AppColor.accentCoral]
            )
            
            QuickStatCard(
                value: "2",
                label: "Roommates",
                icon: "person.2.fill",
                colors: [AppColor.accentLavender, AppColor.powderBlue]
            )
            
            QuickStatCard(
                value: "$85",
                label: "Your Share",
                icon: "dollarsign.circle.fill",
                colors: [AppColor.accentMint, AppColor.accentTeal]
            )
        }
        .padding(.horizontal)
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 30)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15), value: animateCards)
    }
    
    // MARK: - Dashboard Cards Section
    
    private var dashboardCardsSection: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "Overview", subtitle: "Quick access to your household")
                .padding(.horizontal)
            
            VStack(spacing: 14) {
                DashboardCard(
                    icon: "bell.fill",
                    title: "Notifications",
                    subtitle: "Stay updated with house activities",
                    colors: [AppColor.accentCoral, AppColor.accentAmber],
                    badge: "3"
                )
                .opacity(animateCards ? 1 : 0)
                .offset(y: animateCards ? 0 : 40)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateCards)

                DashboardCard(
                    icon: "calendar",
                    title: "Upcoming Tasks",
                    subtitle: "See what's due this week",
                    colors: [AppColor.accentTeal, AppColor.accentSky]
                )
                .opacity(animateCards ? 1 : 0)
                .offset(y: animateCards ? 0 : 40)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.25), value: animateCards)

                DashboardCard(
                    icon: "chart.bar.fill",
                    title: "Recent Expenses",
                    subtitle: "Track shared costs",
                    colors: [AppColor.accentMint, AppColor.accentTeal]
                )
                .opacity(animateCards ? 1 : 0)
                .offset(y: animateCards ? 0 : 40)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: animateCards)
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Activity Section
    
    private var activitySection: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "Recent Activity", actionTitle: "See All") { }
                .padding(.horizontal)
            
            GlassCard {
                VStack(spacing: 0) {
                    ActivityRow(
                        icon: "checkmark.circle.fill",
                        title: "Kitchen cleaned",
                        subtitle: "Completed by Alex",
                        time: "2h ago",
                        colors: [AppColor.accentMint, AppColor.accentTeal]
                    )
                    
                    Divider()
                        .background(AppColor.surface2)
                    
                    ActivityRow(
                        icon: "dollarsign.circle.fill",
                        title: "Groceries split",
                        subtitle: "$42.50 each",
                        time: "5h ago",
                        colors: [AppColor.accentAmber, AppColor.accentCoral]
                    )
                    
                    Divider()
                        .background(AppColor.surface2)
                    
                    ActivityRow(
                        icon: "person.badge.plus",
                        title: "New roommate",
                        subtitle: "Jordan joined the house",
                        time: "1d ago",
                        colors: [AppColor.accentLavender, AppColor.powderBlue]
                    )
                }
            }
            .padding(.horizontal)
            .opacity(animateCards ? 1 : 0)
            .offset(y: animateCards ? 0 : 40)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.35), value: animateCards)
        }
    }
}

// MARK: - Supporting Views

struct QuickStatCard: View {
    let value: String
    let label: String
    let icon: String
    let colors: [Color]
    
    var body: some View {
        GlassCard(accentColor: colors[0]) {
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
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                }
                
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                
                Text(label)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColor.textTertiary)
                    .lineLimit(1)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
        }
    }
}

struct DashboardCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let colors: [Color]
    var badge: String? = nil
    
    var body: some View {
        GlassCard(accentColor: colors[0]) {
            HStack(spacing: 16) {
                GradientIconBadge(icon: icon, colors: colors, size: 52, iconSize: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColor.textPrimary)
                    
                    Text(subtitle)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(AppColor.textSecondary)
                }
                
                Spacer()
                
                if let badge {
                    StatusBadge(text: badge, color: colors[0], style: .filled)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColor.textTertiary)
                }
            }
            .padding(18)
        }
    }
}

struct ActivityRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let time: String
    let colors: [Color]
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: colors.map { $0.opacity(0.15) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 42, height: 42)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(AppColor.textSecondary)
            }
            
            Spacer()
            
            Text(time)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(AppColor.textTertiary)
        }
        .padding(16)
    }
}

#Preview {
    HomePageView()
}
