//
//  ExpensesPageView.swift
//  HomeHero
//
//  Beautiful expenses page with animated cards and summary
//

import SwiftUI

struct ExpensesPageView: View {
    @EnvironmentObject private var householdSession: HouseholdSession
    @State private var animateContent = false
    @State private var selectedPeriod: TimePeriod = .thisMonth
    
    enum TimePeriod: String, CaseIterable {
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        case allTime = "All Time"
    }

    var body: some View {
        NavigationStack {
            HouseholdGateView(
                title: "Join or create a household",
                subtitle: "Expenses are household-specific. Join or create a household to begin."
            ) {
                ZStack {
                    AppColor.dropBackground.ignoresSafeArea()
                    AnimatedBackgroundOrbs()
                        .ignoresSafeArea()

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            // Header
                            headerSection
                            
                            // Summary Card
                            summaryCard
                            
                            // Period Selector
                            periodSelector
                            
                            // Expenses List
                            expensesSection
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Expenses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColor.dropBackground.opacity(0.8), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Add expense action
                    } label: {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [AppColor.accentMint.opacity(0.2), AppColor.accentTeal.opacity(0.15)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [AppColor.accentMint, AppColor.accentTeal],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateContent = true
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColor.accentMint.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)
                
                GradientIconBadge(
                    icon: "dollarsign.circle.fill",
                    colors: [AppColor.accentMint, AppColor.accentTeal],
                    size: 72,
                    iconSize: 32
                )
            }

            VStack(spacing: 8) {
                Text("Expenses")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)

                Text(householdSession.selectedHousehold?.name ?? "Track shared costs")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }
    
    // MARK: - Summary Card
    
    private var summaryCard: some View {
        GlassCard(accentColor: AppColor.accentMint) {
            VStack(spacing: 20) {
                // Total spent
                VStack(spacing: 8) {
                    Text("Total This Month")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(AppColor.textSecondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("$")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColor.textSecondary)
                        Text("1,435")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppColor.accentMint, AppColor.accentTeal],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text(".00")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }
                
                // Divider with gradient
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, AppColor.textTertiary.opacity(0.3), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                
                // Split info
                HStack(spacing: 24) {
                    SummaryStatItem(
                        label: "Your Share",
                        value: "$358.75",
                        icon: "person.fill",
                        colors: [AppColor.accentTeal, AppColor.accentSky]
                    )
                    
                    Rectangle()
                        .fill(AppColor.textTertiary.opacity(0.3))
                        .frame(width: 1, height: 40)
                    
                    SummaryStatItem(
                        label: "You Owe",
                        value: "$42.50",
                        icon: "arrow.up.right",
                        colors: [AppColor.accentCoral, AppColor.accentAmber]
                    )
                    
                    Rectangle()
                        .fill(AppColor.textTertiary.opacity(0.3))
                        .frame(width: 1, height: 40)
                    
                    SummaryStatItem(
                        label: "Owed to You",
                        value: "$85.00",
                        icon: "arrow.down.left",
                        colors: [AppColor.accentMint, AppColor.accentTeal]
                    )
                }
            }
            .padding(22)
        }
        .padding(.horizontal)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 30)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15), value: animateContent)
    }
    
    // MARK: - Period Selector
    
    private var periodSelector: some View {
        HStack(spacing: 8) {
            ForEach(TimePeriod.allCases, id: \.self) { period in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedPeriod = period
                    }
                } label: {
                    Text(period.rawValue)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(selectedPeriod == period ? .white : AppColor.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(
                                    selectedPeriod == period
                                        ? LinearGradient(
                                            colors: [AppColor.accentMint, AppColor.accentTeal],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        : LinearGradient(
                                            colors: [AppColor.surface, AppColor.surface],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                )
                        )
                        .overlay(
                            Capsule()
                                .stroke(
                                    selectedPeriod == period ? .clear : AppColor.textTertiary.opacity(0.3),
                                    lineWidth: 1
                                )
                        )
                }
            }
        }
        .padding(.horizontal)
        .opacity(animateContent ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateContent)
    }
    
    // MARK: - Expenses Section
    
    private var expensesSection: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "Recent Expenses", actionTitle: "See All") { }
                .padding(.horizontal)
            
            VStack(spacing: 14) {
                ExpenseRow(
                    icon: "house.fill",
                    title: "Rent",
                    subtitle: "Jan 1 • Split 4 ways",
                    amount: "$1,200",
                    yourShare: "$300",
                    colors: [AppColor.accentLavender, AppColor.powderBlue]
                )
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 40)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.25), value: animateContent)
                
                ExpenseRow(
                    icon: "bolt.fill",
                    title: "Utilities",
                    subtitle: "Jan 5 • Split 4 ways",
                    amount: "$150",
                    yourShare: "$37.50",
                    colors: [AppColor.accentAmber, AppColor.accentCoral]
                )
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 40)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: animateContent)
                
                ExpenseRow(
                    icon: "cart.fill",
                    title: "Groceries",
                    subtitle: "Jan 12 • Split 2 ways",
                    amount: "$85",
                    yourShare: "$42.50",
                    colors: [AppColor.accentMint, AppColor.accentTeal]
                )
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 40)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.35), value: animateContent)
            }
            .padding(.horizontal)
            
            // Add expense button
            FloatingActionButton(
                icon: "plus.circle.fill",
                title: "Add expense",
                colors: [AppColor.accentMint, AppColor.accentTeal]
            ) {
                // Add expense action
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 40)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: animateContent)
        }
    }
}

// MARK: - Supporting Views

struct SummaryStatItem: View {
    let label: String
    let value: String
    let icon: String
    let colors: [Color]
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: colors.map { $0.opacity(0.15) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }
            
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(AppColor.textPrimary)
            
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(AppColor.textTertiary)
        }
    }
}

struct ExpenseRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let amount: String
    let yourShare: String
    let colors: [Color]
    
    var body: some View {
        GlassCard(accentColor: colors[0]) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: colors.map { $0.opacity(0.15) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: colors.map { $0.opacity(0.4) },
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                }
                
                // Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColor.textPrimary)
                    
                    Text(subtitle)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(AppColor.textSecondary)
                }
                
                Spacer()
                
                // Amount
                VStack(alignment: .trailing, spacing: 4) {
                    Text(amount)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColor.textPrimary)
                    
                    HStack(spacing: 4) {
                        Text("You:")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(AppColor.textTertiary)
                        Text(yourShare)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(colors[0])
                    }
                }
            }
            .padding(18)
        }
    }
}

#Preview {
    ExpensesPageView()
}
