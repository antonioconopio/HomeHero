//
//  HouseholdSelectorMenu.swift
//  HomeHero
//
//  Reusable household selector dropdown for navigation bars
//

import SwiftUI

struct HouseholdSelectorMenu: View {
    @EnvironmentObject private var householdSession: HouseholdSession
    @State private var showCreateHousehold = false
    @State private var showJoinHousehold = false
    @State private var showLeaveConfirmation = false
    @State private var isLeaving = false
    
    var body: some View {
        Menu {
            // Current households
            if !householdSession.households.isEmpty {
                Section("Your Households") {
                    ForEach(householdSession.households) { household in
                        Button {
                            householdSession.selectHousehold(household.id)
                        } label: {
                            HStack {
                                Text(household.name)
                                if household.id == householdSession.selectedHouseholdId {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            }
            
            Divider()
            
            // Actions
            Section {
                Button {
                    showCreateHousehold = true
                } label: {
                    Label("Create Household", systemImage: "plus.circle")
                }
                
                Button {
                    showJoinHousehold = true
                } label: {
                    Label("Join Household", systemImage: "person.2.badge.plus")
                }
                
                // Leave household option (only if a household is selected)
                if householdSession.selectedHouseholdId != nil {
                    Button(role: .destructive) {
                        showLeaveConfirmation = true
                    } label: {
                        Label("Leave Household", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "house.fill")
                    .font(.system(size: 14, weight: .semibold))
                
                Text(householdSession.selectedHousehold?.name ?? "Select Home")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .bold))
            }
            .foregroundStyle(AppColor.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(AppColor.surface.opacity(0.8))
            )
            .overlay(
                Capsule()
                    .stroke(AppColor.textTertiary.opacity(0.3), lineWidth: 1)
            )
        }
        .sheet(isPresented: $showCreateHousehold) {
            CreateHouseholdFlowSheet()
                .environmentObject(householdSession)
        }
        .sheet(isPresented: $showJoinHousehold) {
            JoinHouseholdPlaceholderSheet()
                .environmentObject(householdSession)
        }
        .alert("Leave Household", isPresented: $showLeaveConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Leave", role: .destructive) {
                Task { await leaveCurrentHousehold() }
            }
        } message: {
            Text("Are you sure you want to leave \(householdSession.selectedHousehold?.name ?? "this household")? If you're the last member, the household will be deleted.")
        }
    }
    
    private func leaveCurrentHousehold() async {
        guard let householdId = householdSession.selectedHouseholdId else { return }
        isLeaving = true
        defer { isLeaving = false }
        
        do {
            try await HomeHeroAPI.shared.leaveHousehold(householdId: householdId)
            await householdSession.refresh()
        } catch {
            print("Failed to leave household: \(error)")
        }
    }
}

// Compact version for toolbar
struct HouseholdSelectorToolbarItem: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            HouseholdSelectorMenu()
        }
    }
}

#Preview {
    NavigationStack {
        Text("Content")
            .toolbar {
                HouseholdSelectorToolbarItem()
            }
    }
    .environmentObject(HouseholdSession())
}
