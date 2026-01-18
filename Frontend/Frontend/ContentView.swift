//
//  ContentView.swift
//  Frontend
//
//  Created by Antonio Conopio on 2026-01-17.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            AppColor.mintCream.ignoresSafeArea()

            VStack(spacing: 12) {
                Image(systemName: "house.fill")
                    .imageScale(.large)
                    .foregroundStyle(.tint)

                Text("HomeHero")
                    .font(.title.bold())
                    .foregroundStyle(AppColor.oxfordNavy)

                Text("Palette wired via Assets.xcassets")
                    .font(.subheadline)
                    .foregroundStyle(AppColor.prussianBlue.opacity(0.85))

                HStack(spacing: 10) {
                    ColorSwatch(color: AppColor.regalNavy, title: "#134074")
                    ColorSwatch(color: AppColor.oxfordNavy, title: "#13315C")
                    ColorSwatch(color: AppColor.prussianBlue, title: "#0B2545")
                    ColorSwatch(color: AppColor.powderBlue, title: "#8DA9C4")
                    ColorSwatch(color: AppColor.mintCream, title: "#EEF4ED")
                }
                .padding(.top, 8)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}

// MARK: - Design System

/// Centralized color names for the app.
/// A rich, harmonious palette with deep navy tones and soft accents.
enum AppColor {
    // Primary palette from Assets
    static let regalNavy = Color("RegalNavy")
    static let oxfordNavy = Color("OxfordNavy")
    static let prussianBlue = Color("PrussianBlue")
    static let powderBlue = Color("PowderBlue")
    static let mintCream = Color("MintCream")
    
    // Dark theme surfaces - rich and deep
    static let dropBackground = Color(red: 0.04, green: 0.05, blue: 0.08)
    static let surface = Color(red: 0.08, green: 0.09, blue: 0.14)
    static let surface2 = Color(red: 0.11, green: 0.12, blue: 0.18)
    static let surfaceElevated = Color(red: 0.13, green: 0.14, blue: 0.21)
    
    // Text hierarchy
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.68)
    static let textTertiary = Color.white.opacity(0.45)
    
    // Accent colors for variety and harmony
    static let accentTeal = Color(red: 0.30, green: 0.78, blue: 0.75)
    static let accentCoral = Color(red: 1.0, green: 0.45, blue: 0.42)
    static let accentAmber = Color(red: 1.0, green: 0.72, blue: 0.30)
    static let accentLavender = Color(red: 0.70, green: 0.58, blue: 0.92)
    static let accentMint = Color(red: 0.45, green: 0.88, blue: 0.72)
    static let accentSky = Color(red: 0.40, green: 0.72, blue: 1.0)
    
    // Gradients
    static let primaryGradient = LinearGradient(
        colors: [oxfordNavy, regalNavy],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        colors: [accentTeal, accentSky],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let warmGradient = LinearGradient(
        colors: [accentCoral, accentAmber],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let coolGradient = LinearGradient(
        colors: [accentLavender, powderBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let surfaceGradient = LinearGradient(
        colors: [surface, surface2],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let shimmerGradient = LinearGradient(
        colors: [.white.opacity(0.0), .white.opacity(0.03), .white.opacity(0.0)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Reusable Components

/// A beautiful glass-morphism card with subtle glow
struct GlassCard<Content: View>: View {
    var accentColor: Color = AppColor.powderBlue
    var cornerRadius: CGFloat = 20
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        content()
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(AppColor.surface)
                    
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(AppColor.shimmerGradient)
                    
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.12), .white.opacity(0.04)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: accentColor.opacity(0.08), radius: 20, x: 0, y: 8)
            .shadow(color: .black.opacity(0.35), radius: 16, x: 0, y: 8)
    }
}

/// An icon badge with gradient background
struct GradientIconBadge: View {
    let icon: String
    var colors: [Color] = [AppColor.powderBlue, AppColor.accentTeal]
    var size: CGFloat = 48
    var iconSize: CGFloat = 22
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: colors.map { $0.opacity(0.2) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: colors.map { $0.opacity(0.4) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .frame(width: size, height: size)
            
            Image(systemName: icon)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
}

/// A floating action button with gradient and shadow
struct FloatingActionButton: View {
    let icon: String
    let title: String
    var colors: [Color] = [AppColor.oxfordNavy, AppColor.regalNavy]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                Spacer()
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                    
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppColor.shimmerGradient)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: colors[0].opacity(0.4), radius: 16, x: 0, y: 8)
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
    }
}

/// A secondary outline button
struct SecondaryButton: View {
    let icon: String
    let title: String
    var accentColor: Color = AppColor.powderBlue
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                Spacer()
            }
            .foregroundStyle(AppColor.textPrimary)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppColor.surface)
                    
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [accentColor.opacity(0.3), accentColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
            )
            .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
        }
    }
}

/// A status badge pill
struct StatusBadge: View {
    let text: String
    var color: Color = AppColor.powderBlue
    var style: BadgeStyle = .filled
    
    enum BadgeStyle {
        case filled, outlined
    }
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(style == .filled ? .white : color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(style == .filled ? color : color.opacity(0.15))
            )
            .overlay(
                Capsule()
                    .stroke(color.opacity(style == .filled ? 0 : 0.4), lineWidth: 1)
            )
    }
}

/// A section header with optional action
struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(AppColor.textTertiary)
                }
            }
            
            Spacer()
            
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColor.accentTeal)
                }
            }
        }
    }
}

/// An animated ring progress indicator
struct RingProgress: View {
    let progress: Double
    var size: CGFloat = 60
    var lineWidth: CGFloat = 6
    var colors: [Color] = [AppColor.accentTeal, AppColor.accentSky]
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(AppColor.surface2, lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: colors + [colors[0]],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.8, dampingFraction: 0.8), value: progress)
        }
        .frame(width: size, height: size)
    }
}

/// A beautiful empty state view
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var iconColors: [Color] = [AppColor.powderBlue, AppColor.accentTeal]
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [iconColors[0].opacity(0.15), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                
                GradientIconBadge(icon: icon, colors: iconColors, size: 72, iconSize: 32)
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
        }
        .padding(.vertical, 32)
    }
}

/// A shimmer loading placeholder
struct ShimmerView: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        Rectangle()
            .fill(AppColor.surface2)
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.08), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: phase)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 300
                }
            }
            .clipped()
    }
}

/// Animated background orbs for visual interest
struct AnimatedBackgroundOrbs: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Top-right orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppColor.regalNavy.opacity(0.35), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .offset(x: 120, y: -200)
                .offset(x: animate ? 20 : -20, y: animate ? -15 : 15)
            
            // Bottom-left orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppColor.powderBlue.opacity(0.25), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .offset(x: -140, y: 280)
                .offset(x: animate ? -25 : 25, y: animate ? 20 : -20)
            
            // Center accent orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppColor.accentTeal.opacity(0.12), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .offset(x: 80, y: 120)
                .offset(x: animate ? 15 : -15, y: animate ? -10 : 10)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

private struct ColorSwatch: View {
    let color: Color
    let title: String

    var body: some View {
        VStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(color)
                .frame(width: 44, height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(AppColor.prussianBlue.opacity(0.15), lineWidth: 1)
                )

            Text(title)
                .font(.caption2)
                .foregroundStyle(AppColor.prussianBlue.opacity(0.75))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
    }
}
