package com.HomeHero.demo.service;

import com.HomeHero.demo.model.Expense;
import com.HomeHero.demo.model.ExpenseSplit;
import com.HomeHero.demo.persistance.ExpenseMapper;
import com.HomeHero.demo.persistance.ExpenseSplitMapper;
import com.HomeHero.demo.persistance.ProfileMapper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class ExpenseService {

    private ExpenseMapper expenseMapper;
    private ExpenseSplitMapper expenseSplitMapper;
    private ProfileMapper profileMapper;

    @Autowired
    public ExpenseService(ExpenseMapper expenseMapper, ExpenseSplitMapper expenseSplitMapper, ProfileMapper profileMapper) {
        this.expenseMapper = expenseMapper;
        this.expenseSplitMapper = expenseSplitMapper;
        this.profileMapper = profileMapper;
    }

    public Expense getExpenseById(UUID id) {
        return expenseMapper.getExpenseById(id);
    }

    public List<Expense> getExpensesByHouseholdId(UUID householdId) {
        return expenseMapper.getExpensesByHouseholdId(householdId);
    }

    @Transactional
    public Expense createExpense(UUID householdId, UUID payerProfileId, String item, float cost, int score, List<ExpenseSplit> splits) {
        if (cost <= 0) throw new IllegalArgumentException("Cost must be positive");
        if (item == null || item.isBlank()) throw new IllegalArgumentException("Item cannot be null");

        Expense expense = new Expense();
        expense.setId(UUID.randomUUID());
        expense.setHouseholdId(householdId);
        expense.setProfileId(payerProfileId);
        expense.setItem(item);
        expense.setCost(cost);
        expense.setScore(score);

        expenseMapper.insertExpense(expense);

        if (splits != null && !splits.isEmpty()) {
            // Filter out the payer - they already paid, so they shouldn't be in the split records
            List<ExpenseSplit> othersOnly = splits.stream()
                .filter(s -> !s.getProfileId().equals(payerProfileId))
                .toList();

            if (!othersOnly.isEmpty()) {
                // Split the cost among ALL people involved (payer + others)
                // e.g., $100 split with 2 roommates = $100 / 3 = $33.33 each
                int totalPeople = othersOnly.size() + 1; // +1 for the payer
                float splitCost = cost / totalPeople;

                for (ExpenseSplit split : othersOnly) {
                    split.setExpenseId(expense.getId());
                    split.setAmount(splitCost);
                    split.setPaid(false);
                    expenseSplitMapper.insert(split);

                    // Update balances: the person in the split owes money to the payer
                    profileMapper.incrementAmountOwed(split.getProfileId(), splitCost);
                    profileMapper.incrementAmountOwedToUser(payerProfileId, splitCost);
                }
            }
        }

        return expense;
    }

    @Transactional
    public void updateExpense(UUID expenseId, String item, float cost) {
        expenseMapper.updateExpense(expenseId, item, cost);
    }

    @Transactional
    public void removeExpense(UUID expenseId) {
        // First, reverse all balance changes from splits
        Expense expense = expenseMapper.getExpenseById(expenseId);
        if (expense != null) {
            List<ExpenseSplit> splits = expenseSplitMapper.getSplitsByExpense(expenseId);
            UUID payerProfileId = expense.getProfileId();

            for (ExpenseSplit split : splits) {
                // Only reverse unpaid splits - paid ones have already been settled
                if (!split.isPaid() && !split.getProfileId().equals(payerProfileId)) {
                    // Reverse the balance changes
                    profileMapper.incrementAmountOwed(split.getProfileId(), -split.getAmount());
                    profileMapper.incrementAmountOwedToUser(payerProfileId, -split.getAmount());
                }
            }

            // Delete all splits first
            expenseSplitMapper.deleteSplitsByExpense(expenseId);
        }

        // Then delete the expense
        expenseMapper.deleteExpense(expenseId);
    }

    public List<ExpenseSplit> getSplits(UUID expenseId) {
        return expenseSplitMapper.getSplitsByExpense(expenseId);
    }

    public List<ExpenseSplit> getSplitsByProfileAndHousehold(UUID profileId, UUID householdId) {
        return expenseSplitMapper.getSplitsByProfileAndHousehold(profileId, householdId);
    }

    public float getMonthlyTotalByHousehold(UUID householdId) {
        return expenseMapper.getMonthlyTotalByHousehold(householdId);
    }

    @Transactional
    public void markSplitAsPaid(UUID splitId) {
        ExpenseSplit split = expenseSplitMapper.getSplitById(splitId);
        if (split == null) {
            throw new IllegalArgumentException("Split not found");
        }
        if (split.isPaid()) {
            return; // Already paid
        }

        // Get the expense to find the payer
        Expense expense = expenseMapper.getExpenseById(split.getExpenseId());
        if (expense == null) {
            throw new IllegalArgumentException("Expense not found");
        }

        UUID payerProfileId = expense.getProfileId();
        UUID oweingProfileId = split.getProfileId();

        // Only update balances if the person paying is not the original payer
        if (!oweingProfileId.equals(payerProfileId)) {
            // Reduce the owing person's amount_owed
            profileMapper.incrementAmountOwed(oweingProfileId, -split.getAmount());
            // Reduce the payer's amount_owed_to_user
            profileMapper.incrementAmountOwedToUser(payerProfileId, -split.getAmount());
        }

        // Mark as paid
        expenseSplitMapper.updatePaidStatus(splitId, true);
    }

    @Transactional
    public void markSplitAsUnpaid(UUID splitId) {
        ExpenseSplit split = expenseSplitMapper.getSplitById(splitId);
        if (split == null) {
            throw new IllegalArgumentException("Split not found");
        }
        if (!split.isPaid()) {
            return; // Already unpaid
        }

        // Get the expense to find the payer
        Expense expense = expenseMapper.getExpenseById(split.getExpenseId());
        if (expense == null) {
            throw new IllegalArgumentException("Expense not found");
        }

        UUID payerProfileId = expense.getProfileId();
        UUID oweingProfileId = split.getProfileId();

        // Only update balances if the person is not the original payer
        if (!oweingProfileId.equals(payerProfileId)) {
            // Increase the owing person's amount_owed back
            profileMapper.incrementAmountOwed(oweingProfileId, split.getAmount());
            // Increase the payer's amount_owed_to_user back
            profileMapper.incrementAmountOwedToUser(payerProfileId, split.getAmount());
        }

        // Mark as unpaid
        expenseSplitMapper.updatePaidStatus(splitId, false);
    }
}