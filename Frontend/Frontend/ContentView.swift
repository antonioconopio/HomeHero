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
                    .foregroundStyle(.tint) // uses AccentColor (currently OxfordNavy)

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

/// Centralized color names for the app.
/// To tweak colors later, edit values in `Assets.xcassets` (no code changes needed).
enum AppColor {
    static let regalNavy = Color("RegalNavy")
    static let oxfordNavy = Color("OxfordNavy")
    static let prussianBlue = Color("PrussianBlue")
    static let powderBlue = Color("PowderBlue")
    static let mintCream = Color("MintCream")
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
