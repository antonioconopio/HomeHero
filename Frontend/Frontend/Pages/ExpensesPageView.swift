//
//  ExpensesPageView.swift
//  HomeHero
//
//  Temporary expenses page placeholder
//

import SwiftUI

struct ExpensesPageView: View {
    @EnvironmentObject private var householdSession: HouseholdSession

    var body: some View {
        NavigationStack {
            HouseholdGateView(
                title: "Join or create a household",
                subtitle: "Expenses are household-specific. Join or create a household to begin."
            ) {
                ZStack {
                    AppColor.mintCream.ignoresSafeArea()

                    VStack(spacing: 20) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(AppColor.oxfordNavy)

                        Text("Expenses")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColor.oxfordNavy)

                        Text(householdSession.selectedHousehold?.name ?? "")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundStyle(AppColor.prussianBlue.opacity(0.70))

                        Spacer()
                            .frame(height: 24)

                        VStack(spacing: 12) {
                            ExpensePlaceholderRow(
                                title: "Rent",
                                amount: "$1,200",
                                date: "Jan 1"
                            )
                            ExpensePlaceholderRow(
                                title: "Utilities",
                                amount: "$150",
                                date: "Jan 5"
                            )
                            ExpensePlaceholderRow(
                                title: "Groceries",
                                amount: "$85",
                                date: "Jan 12"
                            )
                        }
                        .padding(.horizontal)

                        Spacer()
                    }
                    .padding(.top, 24)
                }
            }
            .navigationTitle("Expenses")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ExpensePlaceholderRow: View {
    let title: String
    let amount: String
    let date: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(AppColor.powderBlue)
                .frame(width: 44, height: 44)
                .background(AppColor.powderBlue.opacity(0.15))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColor.oxfordNavy)
                
                Text(date)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(AppColor.prussianBlue.opacity(0.60))
            }
            
            Spacer()
            
            Text(amount)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColor.oxfordNavy)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    ExpensesPageView()
}
