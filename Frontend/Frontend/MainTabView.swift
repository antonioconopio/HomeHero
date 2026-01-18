//
//  MainTabView.swift
//  HomeHero
//
//  Main tab navigation with custom animated tab bar
//

import SwiftUI

struct MainTabView: View {
    @Binding var showSignedInView: Bool
    @State private var selectedTab: Tab = .home
    @Namespace private var tabAnimation
    
    enum Tab: String, CaseIterable {
        case home = "Home"
        case tasks = "Tasks"
        case expenses = "Expenses"
        case profile = "Profile"
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .tasks: return "checklist"
            case .expenses: return "dollarsign.circle.fill"
            case .profile: return "person.fill"
            }
        }
        
        var iconColors: [Color] {
            switch self {
            case .home: return [AppColor.accentTeal, AppColor.accentSky]
            case .tasks: return [AppColor.accentAmber, AppColor.accentCoral]
            case .expenses: return [AppColor.accentMint, AppColor.accentTeal]
            case .profile: return [AppColor.accentLavender, AppColor.powderBlue]
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Tab content
                Group {
                    switch selectedTab {
                    case .home:
                        HomePageView()
                    case .tasks:
                        TasksPageView()
                    case .expenses:
                        ExpensesPageView()
                    case .profile:
                        ProfilePageView(showSignedInView: $showSignedInView)
                    }
                }
                
                // Custom tab bar - flush to bottom
                CustomTabBar(selectedTab: $selectedTab, tabAnimation: tabAnimation)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .ignoresSafeArea(.keyboard)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: MainTabView.Tab
    var tabAnimation: Namespace.ID
    
    private var bottomSafeArea: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom ?? 0
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab buttons
            HStack(spacing: 0) {
                ForEach(MainTabView.Tab.allCases, id: \.self) { tab in
                    TabBarButton(
                        tab: tab,
                        isSelected: selectedTab == tab,
                        tabAnimation: tabAnimation
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            // Safe area spacer - extends background to bottom edge
            Color.clear
                .frame(height: bottomSafeArea)
        }
        .background(
            ZStack {
                // Solid background that extends to edge
                AppColor.surface
                
                // Blur background
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
                
                // Gradient overlay
                LinearGradient(
                    colors: [AppColor.surface.opacity(0.95), AppColor.surface.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Top border glow
                VStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    selectedTab.iconColors[0].opacity(0.4),
                                    selectedTab.iconColors[1].opacity(0.2),
                                    .clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 1)
                    Spacer()
                }
            }
        )
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 24,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 24,
                style: .continuous
            )
        )
        .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: -5)
    }
}

struct TabBarButton: View {
    let tab: MainTabView.Tab
    let isSelected: Bool
    var tabAnimation: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: tab.iconColors.map { $0.opacity(0.2) },
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 36)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(
                                        LinearGradient(
                                            colors: tab.iconColors.map { $0.opacity(0.5) },
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .matchedGeometryEffect(id: "tabIndicator", in: tabAnimation)
                    }
                    
                    Image(systemName: tab.icon)
                        .font(.system(size: isSelected ? 20 : 22, weight: .semibold))
                        .foregroundStyle(
                            isSelected
                                ? AnyShapeStyle(LinearGradient(colors: tab.iconColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                                : AnyShapeStyle(AppColor.textTertiary)
                        )
                        .scaleEffect(isSelected ? 1.0 : 0.9)
                }
                .frame(height: 36)
                
                Text(tab.rawValue)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium, design: .rounded))
                    .foregroundStyle(isSelected ? tab.iconColors[0] : AppColor.textTertiary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainTabView(showSignedInView: .constant(false))
}
