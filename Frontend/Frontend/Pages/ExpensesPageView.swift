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
    
    // Data state
    @State private var expenses: [HomeHeroAPI.Expense] = []
    @State private var monthlyTotal: Float = 0
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // Sheet state
    @State private var showCreateExpense = false
    @State private var showExpenseDetail: HomeHeroAPI.Expense?
    
    enum TimePeriod: String, CaseIterable {
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        case allTime = "All Time"
    }
    
    private var myProfileId: UUID? {
        householdSession.me?.id
    }
    
    private var youOweAmount: Float {
        householdSession.me?.amountOwed ?? 0
    }
    
    private var owedToYouAmount: Float {
        householdSession.me?.amountOwedToUser ?? 0
    }
    
    private var filteredExpenses: [HomeHeroAPI.Expense] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .thisWeek:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            return expenses.filter { ($0.createdAt ?? now) >= weekAgo }
        case .thisMonth:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return expenses.filter { ($0.createdAt ?? now) >= monthAgo }
        case .allTime:
            return expenses
        }
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
                    
                    if isLoading {
                        ProgressView()
                            .tint(AppColor.accentMint)
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
                        showCreateExpense = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                            Text("Add Expense")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColor.accentMint, AppColor.accentTeal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [AppColor.accentMint.opacity(0.15), AppColor.accentTeal.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            Capsule()
                                .stroke(AppColor.accentMint.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
            }
        }
        .task {
            await loadExpenses()
        }
        .refreshable {
            await loadExpenses()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateContent = true
            }
        }
        .sheet(isPresented: $showCreateExpense) {
            CreateExpenseSheet(onCreated: {
                Task { await loadExpenses() }
            })
            .environmentObject(householdSession)
        }
        .sheet(item: $showExpenseDetail) { expense in
            ExpenseDetailSheet(expense: expense, onUpdated: {
                Task { await loadExpenses() }
            })
            .environmentObject(householdSession)
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    private func loadExpenses() async {
        guard let householdId = householdSession.selectedHouseholdId else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            async let expensesTask = HomeHeroAPI.shared.getExpenses(householdId: householdId)
            async let monthlyTask = HomeHeroAPI.shared.getMonthlyTotal(householdId: householdId)
            
            let (fetchedExpenses, fetchedMonthly) = try await (expensesTask, monthlyTask)
            
            await MainActor.run {
                self.expenses = fetchedExpenses
                self.monthlyTotal = fetchedMonthly
            }
            
            // Also refresh profile to get updated balances
            await householdSession.refresh()
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
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
                    
                    Text(formatCurrency(monthlyTotal))
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColor.accentMint, AppColor.accentTeal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
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
                        label: "You Owe",
                        value: formatCurrency(youOweAmount),
                        icon: "arrow.up.right",
                        colors: [AppColor.accentCoral, AppColor.accentAmber]
                    )
                    
                    Rectangle()
                        .fill(AppColor.textTertiary.opacity(0.3))
                        .frame(width: 1, height: 40)
                    
                    SummaryStatItem(
                        label: "Owed to You",
                        value: formatCurrency(owedToYouAmount),
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
    
    private func formatCurrency(_ amount: Float) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
//        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
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
            SectionHeader(title: "Recent Expenses", subtitle: "\(filteredExpenses.count) expenses")
                .padding(.horizontal)
            
            if filteredExpenses.isEmpty {
                GlassCard {
                    VStack(spacing: 12) {
                        Image(systemName: "dollarsign.circle")
                            .font(.system(size: 40))
                            .foregroundStyle(AppColor.textTertiary)
                        Text("No expenses yet")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(AppColor.textSecondary)
                        Text("Add your first shared expense")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundStyle(AppColor.textTertiary)
                    }
                    .padding(24)
                }
                .padding(.horizontal)
            } else {
                VStack(spacing: 14) {
                    ForEach(Array(filteredExpenses.enumerated()), id: \.element.id) { index, expense in
                        let mySplit = expense.splits?.first { $0.profileId == myProfileId }
                        let needsPayment = mySplit != nil && !mySplit!.paid && expense.profileId != myProfileId
                        let splitCount = expense.splits?.count ?? 0
                        
                        ExpenseRowView(
                            expense: expense,
                            mySplit: mySplit,
                            needsPayment: needsPayment,
                            splitCount: splitCount,
                            formatCurrency: formatCurrency
                        )
                        .onTapGesture {
                            showExpenseDetail = expense
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 40)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.25 + Double(index) * 0.05), value: animateContent)
                    }
                }
                .padding(.horizontal)
            }
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

struct ExpenseRowView: View {
    let expense: HomeHeroAPI.Expense
    let mySplit: HomeHeroAPI.ExpenseSplit?
    let needsPayment: Bool
    let splitCount: Int
    let formatCurrency: (Float) -> String
    
    private var colors: [Color] {
        needsPayment ? [AppColor.accentCoral, AppColor.accentAmber] : [AppColor.accentMint, AppColor.accentTeal]
    }
    
    private var dateString: String {
        guard let date = expense.createdAt else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        GlassCard(accentColor: colors[0]) {
            HStack(spacing: 16) {
                // Icon with alert indicator
                ZStack(alignment: .topTrailing) {
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
                        
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                    }
                    
                    // Alert badge for unpaid splits
                    if needsPayment {
                        Circle()
                            .fill(AppColor.accentCoral)
                            .frame(width: 18, height: 18)
                            .overlay(
                                Image(systemName: "exclamationmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 4, y: -4)
                    }
                }
                
                // Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(expense.item)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColor.textPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        Text(dateString)
                        if splitCount > 0 {
                            Text("•")
                            Text("Split \(splitCount) ways")
                        }
                    }
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(AppColor.textSecondary)
                    
                    if needsPayment {
                        Text("Payment needed")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppColor.accentCoral)
                    }
                }
                
                Spacer()
                
                // Amount
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatCurrency(expense.cost))
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColor.textPrimary)
                    
                    if let split = mySplit {
                        HStack(spacing: 4) {
                            Text("You:")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundStyle(AppColor.textTertiary)
                            Text(formatCurrency(split.amount))
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(split.paid ? AppColor.accentMint : colors[0])
                        }
                        
                        if split.paid {
                            Text("Paid")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppColor.accentMint)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppColor.accentMint.opacity(0.15))
                                .cornerRadius(4)
                        }
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColor.textTertiary)
            }
            .padding(18)
        }
    }
}

// MARK: - Create Expense Sheet

struct CreateExpenseSheet: View {
    @EnvironmentObject private var householdSession: HouseholdSession
    @Environment(\.dismiss) private var dismiss
    
    @State private var expenseName = ""
    @State private var expenseAmount = ""
    @State private var selectedMemberIds: Set<UUID> = []
    @State private var householdMembers: [HomeHeroAPI.Profile] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    let onCreated: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.dropBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Expense Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Expense Name")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(AppColor.textSecondary)
                            
                            TextField("e.g., Groceries, Rent, Utilities", text: $expenseName)
                                .font(.system(size: 16, design: .rounded))
                                .padding(16)
                                .background(AppColor.surface)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppColor.textTertiary.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        // Amount
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Amount")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(AppColor.textSecondary)
                            
                            HStack {
                                Text("$")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(AppColor.textSecondary)
                                
                                TextField("0.00", text: $expenseAmount)
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .keyboardType(.decimalPad)
                            }
                            .padding(16)
                            .background(AppColor.surface)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppColor.textTertiary.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        // Split With
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Split With")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(AppColor.textSecondary)
                            
                            Text("Select who owes you for this expense")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundStyle(AppColor.textTertiary)
                            
                            if householdMembers.isEmpty {
                                Text("Loading members...")
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundStyle(AppColor.textTertiary)
                            } else {
                                // Only show other members, not the current user (payer)
                                let otherMembers = householdMembers.filter { $0.id != householdSession.me?.id }
                                
                                if otherMembers.isEmpty {
                                    Text("No other household members to split with")
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundStyle(AppColor.textTertiary)
                                        .padding(.vertical, 8)
                                } else {
                                    ForEach(otherMembers) { member in
                                        MemberSelectionRow(
                                            member: member,
                                            isSelected: selectedMemberIds.contains(member.id),
                                            isCurrentUser: false
                                        ) {
                                            if selectedMemberIds.contains(member.id) {
                                                selectedMemberIds.remove(member.id)
                                            } else {
                                                selectedMemberIds.insert(member.id)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            if !selectedMemberIds.isEmpty, let amount = Float(expenseAmount), amount > 0 {
                                // Split among selected members + yourself
                                let totalPeople = selectedMemberIds.count + 1
                                let splitAmount = amount / Float(totalPeople)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Split \(totalPeople) ways: \(formatCurrency(splitAmount)) each")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundStyle(AppColor.accentMint)
                                    Text("Each person owes you: \(formatCurrency(splitAmount))")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundStyle(AppColor.textSecondary)
                                }
                                .padding(.top, 8)
                            } else if selectedMemberIds.isEmpty && !householdMembers.filter({ $0.id != householdSession.me?.id }).isEmpty {
                                Text("No one selected - expense will be tracked without splits")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundStyle(AppColor.textTertiary)
                                    .padding(.top, 8)
                            }
                        }
                        
                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundStyle(AppColor.accentCoral)
                                .padding()
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { await createExpense() }
                    }
                    .disabled(expenseName.isEmpty || expenseAmount.isEmpty || isLoading)
                }
            }
        }
        .task {
            await loadMembers()
        }
    }
    
    private func loadMembers() async {
        guard let householdId = householdSession.selectedHouseholdId else { return }
        
        do {
            let members = try await HomeHeroAPI.shared.getMembers(householdId: householdId)
            await MainActor.run {
                self.householdMembers = members
                // Don't pre-select anyone - user chooses who owes them
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func createExpense() async {
        guard let householdId = householdSession.selectedHouseholdId,
              let myId = householdSession.me?.id,
              let cost = Float(expenseAmount) else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Pass nil if no members selected, otherwise pass the selected IDs
            let splitIds: [UUID]? = selectedMemberIds.isEmpty ? nil : Array(selectedMemberIds)
            
            _ = try await HomeHeroAPI.shared.createExpense(
                householdId: householdId,
                payerProfileId: myId,
                item: expenseName,
                cost: cost,
                splitWithProfileIds: splitIds
            )
            
            await MainActor.run {
                onCreated()
                dismiss()
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func formatCurrency(_ amount: Float) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
//        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

struct MemberSelectionRow: View {
    let member: HomeHeroAPI.Profile
    let isSelected: Bool
    let isCurrentUser: Bool
    let onTap: () -> Void
    
    private var displayName: String {
        let first = member.firstName ?? ""
        let last = member.lastName ?? ""
        let full = [first, last].filter { !$0.isEmpty }.joined(separator: " ")
        return full.isEmpty ? (member.email ?? "Unknown") : full
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColor.accentLavender, AppColor.powderBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Text(String(displayName.prefix(1)).uppercased())
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(displayName)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(AppColor.textPrimary)
                        
                        if isCurrentUser {
                            Text("(You)")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundStyle(AppColor.textTertiary)
                        }
                    }
                    
                    if let email = member.email {
                        Text(email)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(isSelected ? AppColor.accentMint : AppColor.textTertiary.opacity(0.5), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(AppColor.accentMint)
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .padding(14)
            .background(AppColor.surface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppColor.accentMint.opacity(0.5) : AppColor.textTertiary.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

// MARK: - Expense Detail Sheet

struct ExpenseDetailSheet: View {
    @EnvironmentObject private var householdSession: HouseholdSession
    @Environment(\.dismiss) private var dismiss
    
    let expense: HomeHeroAPI.Expense
    let onUpdated: () -> Void
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showDeleteConfirm = false
    @State private var householdMembers: [UUID: HomeHeroAPI.Profile] = [:]
    
    private var isMyExpense: Bool {
        expense.profileId == householdSession.me?.id
    }
    
    private var mySplit: HomeHeroAPI.ExpenseSplit? {
        expense.splits?.first { $0.profileId == householdSession.me?.id }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.dropBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Expense Header
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [AppColor.accentMint.opacity(0.2), AppColor.accentTeal.opacity(0.15)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.system(size: 36))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [AppColor.accentMint, AppColor.accentTeal],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            
                            Text(expense.item)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(AppColor.textPrimary)
                            
                            Text(formatCurrency(expense.cost))
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [AppColor.accentMint, AppColor.accentTeal],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            if let date = expense.createdAt {
                                Text(formatDate(date))
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundStyle(AppColor.textSecondary)
                            }
                        }
                        .padding(.top, 16)
                        
                        // Splits Section
                        if let splits = expense.splits, !splits.isEmpty {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Split Details")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundStyle(AppColor.textPrimary)
                                    .padding(.horizontal)
                                
                                ForEach(splits) { split in
                                    SplitDetailRow(
                                        split: split,
                                        memberName: getMemberName(for: split.profileId),
                                        isCurrentUser: split.profileId == householdSession.me?.id,
                                        isPayer: split.profileId == expense.profileId,
                                        canMarkPaid: split.profileId == householdSession.me?.id && !split.paid && expense.profileId != householdSession.me?.id,
                                        formatCurrency: formatCurrency
                                    ) {
                                        Task { await markAsPaid(splitId: split.id) }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Actions
                        if isMyExpense {
                            Button(action: { showDeleteConfirm = true }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Delete Expense")
                                }
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .background(
                                    LinearGradient(
                                        colors: [AppColor.accentCoral.opacity(0.9), AppColor.accentCoral.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                        
                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundStyle(AppColor.accentCoral)
                        }
                    }
                    .padding(.bottom, 40)
                }
                
                if isLoading {
                    ProgressView()
                        .tint(AppColor.accentMint)
                }
            }
            .navigationTitle("Expense Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Delete Expense?", isPresented: $showDeleteConfirm) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task { await deleteExpense() }
                }
            } message: {
                Text("This will delete the expense and reverse any balance changes. This action cannot be undone.")
            }
        }
        .task {
            await loadMembers()
        }
    }
    
    private func loadMembers() async {
        guard let householdId = householdSession.selectedHouseholdId else { return }
        
        do {
            let members = try await HomeHeroAPI.shared.getMembers(householdId: householdId)
            await MainActor.run {
                self.householdMembers = Dictionary(uniqueKeysWithValues: members.map { ($0.id, $0) })
            }
        } catch {
            // Silently fail - names will just be "Unknown"
        }
    }
    
    private func getMemberName(for profileId: UUID) -> String {
        if let member = householdMembers[profileId] {
            let first = member.firstName ?? ""
            let last = member.lastName ?? ""
            let full = [first, last].filter { !$0.isEmpty }.joined(separator: " ")
            return full.isEmpty ? (member.email ?? "Unknown") : full
        }
        return "Unknown"
    }
    
    private func markAsPaid(splitId: UUID) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await HomeHeroAPI.shared.markSplitAsPaid(splitId: splitId)
            await MainActor.run {
                onUpdated()
                dismiss()
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func deleteExpense() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await HomeHeroAPI.shared.deleteExpense(expenseId: expense.id)
            await MainActor.run {
                onUpdated()
                dismiss()
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func formatCurrency(_ amount: Float) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
//        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct SplitDetailRow: View {
    let split: HomeHeroAPI.ExpenseSplit
    let memberName: String
    let isCurrentUser: Bool
    let isPayer: Bool
    let canMarkPaid: Bool
    let formatCurrency: (Float) -> String
    let onMarkPaid: () -> Void
    
    var body: some View {
        GlassCard(accentColor: split.paid ? AppColor.accentMint : (canMarkPaid ? AppColor.accentCoral : AppColor.accentTeal)) {
            HStack(spacing: 14) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColor.accentLavender, AppColor.powderBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Text(String(memberName.prefix(1)).uppercased())
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                // Name & status
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(memberName)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(AppColor.textPrimary)
                        
                        if isCurrentUser {
                            Text("(You)")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundStyle(AppColor.textTertiary)
                        }
                        
                        if isPayer {
                            Text("• Paid for this")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundStyle(AppColor.accentMint)
                        }
                    }
                    
                    Text(formatCurrency(split.amount))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColor.textSecondary)
                }
                
                Spacer()
                
                // Status / Action
                if split.paid || isPayer {
                    Text(isPayer ? "Payer" : "Paid")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColor.accentMint)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppColor.accentMint.opacity(0.15))
                        .cornerRadius(8)
                } else if canMarkPaid {
                    Button(action: onMarkPaid) {
                        Text("Mark Paid")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    colors: [AppColor.accentMint, AppColor.accentTeal],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(8)
                    }
                } else {
                    Text("Unpaid")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColor.accentCoral)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppColor.accentCoral.opacity(0.15))
                        .cornerRadius(8)
                }
            }
            .padding(16)
        }
    }
}

#Preview {
    ExpensesPageView()
        .environmentObject(HouseholdSession())
}
