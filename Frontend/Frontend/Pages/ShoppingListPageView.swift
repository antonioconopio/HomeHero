//
//  ShoppingListPageView.swift
//  Frontend
//
//  Shopping list page with add and check-off functionality
//

import SwiftUI

struct ShoppingListPageView: View {
    @EnvironmentObject private var householdSession: HouseholdSession
    
    @State private var groceries: [HomeHeroAPI.Grocery] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var animateContent = false
    
    @State private var showAddSheet = false
    @State private var editingGrocery: HomeHeroAPI.Grocery?
    
    var body: some View {
        NavigationStack {
            HouseholdGateView(
                title: "Join or create a household",
                subtitle: "Shopping lists are household-specific. Join or create a household to begin."
            ) {
                ZStack {
                    AppColor.dropBackground.ignoresSafeArea()
                    AnimatedBackgroundOrbs()
                        .ignoresSafeArea()
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            header
                            content
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColor.dropBackground.opacity(0.8), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                HouseholdSelectorToolbarItem()
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
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
                    .accessibilityLabel("Add item")
                    .disabled(householdSession.selectedHousehold == nil)
                }
            }
            .task {
                await refresh()
            }
            .refreshable {
                await refresh()
            }
            .sheet(isPresented: $showAddSheet) {
                if let household = householdSession.selectedHousehold {
                    AddGrocerySheet(householdId: household.id) { name in
                        await createGrocery(name: name)
                    }
                }
            }
            .sheet(item: $editingGrocery) { grocery in
                if let household = householdSession.selectedHousehold {
                    EditGrocerySheet(grocery: grocery, householdId: household.id) { name in
                        await updateGrocery(grocery: grocery, name: name)
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
    
    // MARK: - Header
    
    private var header: some View {
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
                    icon: "cart.fill",
                    colors: [AppColor.accentMint, AppColor.accentTeal],
                    size: 72,
                    iconSize: 32
                )
            }
            
            VStack(spacing: 8) {
                Text("Shopping List")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                
                Text("Tap the checkbox to mark items as bought.")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }
    
    // MARK: - Content
    
    private var content: some View {
        VStack(spacing: 16) {
            if let errorMessage {
                GroceryErrorCard(message: errorMessage) {
                    Task { await refresh() }
                }
                .padding(.horizontal)
            }
            
            // Summary Card
            if !groceries.isEmpty {
                summaryCard
            }
            
            // Add Item Button
            if householdSession.selectedHousehold != nil {
                FloatingActionButton(
                    icon: "plus.circle.fill",
                    title: "Add item",
                    colors: [AppColor.accentMint, AppColor.accentTeal]
                ) {
                    showAddSheet = true
                }
                .padding(.horizontal)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 30)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15), value: animateContent)
            }
            
            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .tint(AppColor.accentMint)
                    Text("Loading items...")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(AppColor.textSecondary)
                }
                .padding(.top, 32)
            } else if groceries.isEmpty {
                EmptyStateView(
                    icon: "cart",
                    title: "No items yet",
                    subtitle: "Tap + to add your first item to the shopping list.",
                    iconColors: [AppColor.accentMint, AppColor.accentTeal]
                )
                .opacity(animateContent ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateContent)
            } else {
                VStack(spacing: 14) {
                    ForEach(Array(groceries.enumerated()), id: \.element.id) { index, grocery in
                        GroceryRow(
                            grocery: grocery,
                            onCheck: {
                                Task { await deleteGrocery(grocery) }
                            },
                            onEdit: {
                                editingGrocery = grocery
                            }
                        )
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 40)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1 + Double(index) * 0.05), value: animateContent)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Summary Card
    
    private var summaryCard: some View {
        GlassCard(accentColor: AppColor.accentTeal) {
            HStack(spacing: 12) {
                GradientIconBadge(
                    icon: "list.bullet.clipboard",
                    colors: [AppColor.accentTeal, AppColor.accentSky],
                    size: 44,
                    iconSize: 18
                )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(groceries.count) item\(groceries.count == 1 ? "" : "s")")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColor.textPrimary)
                    
                    Text("to buy")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(AppColor.textSecondary)
                }
                
                Spacer()
            }
            .padding(18)
        }
        .padding(.horizontal)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.12), value: animateContent)
    }
    
    // MARK: - Actions
    
    @MainActor
    private func refresh() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        await householdSession.refresh()
        await loadGroceries()
    }
    
    @MainActor
    private func loadGroceries() async {
        guard let householdId = householdSession.selectedHousehold?.id else {
            groceries = []
            return
        }
        do {
            groceries = try await HomeHeroAPI.shared.getGroceries(householdId: householdId)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    private func createGrocery(name: String) async {
        guard let householdId = householdSession.selectedHousehold?.id else { return }
        
        do {
            let newGrocery = try await HomeHeroAPI.shared.createGrocery(householdId: householdId, name: name)
            groceries.append(newGrocery)
            showAddSheet = false
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    private func updateGrocery(grocery: HomeHeroAPI.Grocery, name: String) async {
        guard let householdId = householdSession.selectedHousehold?.id,
              let groceryId = grocery.id else { return }
        
        do {
            let updated = try await HomeHeroAPI.shared.updateGrocery(id: groceryId, householdId: householdId, name: name)
            if let index = groceries.firstIndex(where: { $0.id == groceryId }) {
                groceries[index] = updated
            }
            editingGrocery = nil
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    private func deleteGrocery(_ grocery: HomeHeroAPI.Grocery) async {
        let previous = groceries
        
        // Animate removal
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            groceries.removeAll { $0.id == grocery.id }
        }
        
        do {
            _ = try await HomeHeroAPI.shared.deleteGrocery(grocery)
            errorMessage = nil
        } catch {
            groceries = previous
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Grocery Row

private struct GroceryRow: View {
    let grocery: HomeHeroAPI.Grocery
    let onCheck: () -> Void
    let onEdit: () -> Void
    
    @State private var isChecked = false
    
    var body: some View {
        GlassCard(accentColor: AppColor.accentMint) {
            HStack(spacing: 16) {
                // Checkbox
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isChecked = true
                    }
                    // Delay the delete to show the check animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onCheck()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [AppColor.accentMint, AppColor.accentTeal],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 28, height: 28)
                        
                        if isChecked {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [AppColor.accentMint, AppColor.accentTeal],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 28, height: 28)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .buttonStyle(.plain)
                
                // Item name
                Text(grocery.displayName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(isChecked ? AppColor.textTertiary : AppColor.textPrimary)
                    .strikethrough(isChecked, color: AppColor.textTertiary)
                
                Spacer()
                
                // Edit button
                Button {
                    onEdit()
                } label: {
                    ZStack {
                        Circle()
                            .fill(AppColor.accentSky.opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "pencil")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AppColor.accentSky)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(18)
        }
    }
}

// MARK: - Error Card

private struct GroceryErrorCard: View {
    let message: String
    let retry: () -> Void
    
    var body: some View {
        GlassCard(accentColor: AppColor.accentCoral) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    GradientIconBadge(
                        icon: "exclamationmark.triangle.fill",
                        colors: [AppColor.accentCoral, AppColor.accentAmber],
                        size: 44,
                        iconSize: 20
                    )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Couldn't load data")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppColor.textPrimary)
                        
                        Text(message)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(AppColor.textSecondary)
                            .lineLimit(2)
                    }
                }
                
                Button(action: retry) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Retry")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(AppColor.accentCoral)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(AppColor.accentCoral.opacity(0.15))
                    )
                }
            }
            .padding(18)
        }
    }
}

// MARK: - Add Grocery Sheet

private struct AddGrocerySheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let householdId: UUID
    let onCreate: (_ name: String) async -> Void
    
    @State private var name = ""
    @State private var isCreating = false
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.dropBackground.ignoresSafeArea()
                AnimatedBackgroundOrbs()
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        headerSection
                        formCard
                        createButton
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
        }
    }
    
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
                    icon: "cart.badge.plus",
                    colors: [AppColor.accentMint, AppColor.accentTeal],
                    size: 72,
                    iconSize: 32
                )
            }
            
            VStack(spacing: 8) {
                Text("Add Item")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                
                Text("Add a new item to your shopping list")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var formCard: some View {
        GlassCard(accentColor: AppColor.accentMint) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Item Name")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                
                TextField("e.g. Milk, Bread, Eggs...", text: $name)
                    .textInputAutocapitalization(.sentences)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(AppColor.surface2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(AppColor.textTertiary.opacity(0.3), lineWidth: 1)
                    )
            }
            .padding(18)
        }
    }
    
    private var createButton: some View {
        Button {
            Task {
                isCreating = true
                defer { isCreating = false }
                await onCreate(name.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        } label: {
            HStack(spacing: 12) {
                if isCreating {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Add Item")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: isValid
                                    ? [AppColor.accentMint, AppColor.accentTeal]
                                    : [AppColor.textTertiary, AppColor.textTertiary.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    if isValid {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AppColor.shimmerGradient)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: isValid ? AppColor.accentMint.opacity(0.35) : .clear, radius: 16, x: 0, y: 8)
        }
        .disabled(!isValid || isCreating)
    }
}

// MARK: - Edit Grocery Sheet

private struct EditGrocerySheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let grocery: HomeHeroAPI.Grocery
    let householdId: UUID
    let onUpdate: (_ name: String) async -> Void
    
    @State private var name: String
    @State private var isUpdating = false
    
    init(grocery: HomeHeroAPI.Grocery, householdId: UUID, onUpdate: @escaping (_ name: String) async -> Void) {
        self.grocery = grocery
        self.householdId = householdId
        self.onUpdate = onUpdate
        _name = State(initialValue: grocery.displayName)
    }
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.dropBackground.ignoresSafeArea()
                AnimatedBackgroundOrbs()
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        headerSection
                        formCard
                        updateButton
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColor.accentSky.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)
                
                GradientIconBadge(
                    icon: "pencil.circle.fill",
                    colors: [AppColor.accentSky, AppColor.accentTeal],
                    size: 72,
                    iconSize: 32
                )
            }
            
            VStack(spacing: 8) {
                Text("Edit Item")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                
                Text("Update the item name")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var formCard: some View {
        GlassCard(accentColor: AppColor.accentSky) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Item Name")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                
                TextField("e.g. Milk, Bread, Eggs...", text: $name)
                    .textInputAutocapitalization(.sentences)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundStyle(AppColor.textPrimary)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(AppColor.surface2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(AppColor.textTertiary.opacity(0.3), lineWidth: 1)
                    )
            }
            .padding(18)
        }
    }
    
    private var updateButton: some View {
        Button {
            Task {
                isUpdating = true
                defer { isUpdating = false }
                await onUpdate(name.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        } label: {
            HStack(spacing: 12) {
                if isUpdating {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Save Changes")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: isValid
                                    ? [AppColor.accentSky, AppColor.accentTeal]
                                    : [AppColor.textTertiary, AppColor.textTertiary.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    if isValid {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AppColor.shimmerGradient)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: isValid ? AppColor.accentSky.opacity(0.35) : .clear, radius: 16, x: 0, y: 8)
        }
        .disabled(!isValid || isUpdating)
    }
}

#Preview {
    ShoppingListPageView()
        .environmentObject(HouseholdSession())
}
