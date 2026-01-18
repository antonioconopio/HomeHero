package com.HomeHero.demo.service;

import com.HomeHero.demo.model.Expense;
import com.HomeHero.demo.model.ExpenseSplit;
import com.HomeHero.demo.persistance.ExpenseMapper;
import com.HomeHero.demo.persistance.ExpenseSplitMapper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class ExpenseService {

    private ExpenseMapper expenseMapper;
    private ExpenseSplitMapper expenseSplitMapper;

    @Autowired
    public ExpenseService(ExpenseMapper expenseMapper, ExpenseSplitMapper expenseSplitMapper) {
        this.expenseMapper = expenseMapper;
        this.expenseSplitMapper = expenseSplitMapper;
    }

    public Expense getExpenseById(UUID id) {
        return expenseMapper.getExpenseById(id);
    }

    public List<Expense> getExpensesByHouseholdId(UUID householdId) {
        return expenseMapper.getExpensesByHouseholdId(householdId);
    }

    @Transactional
    public Expense createExpense(UUID householdId, UUID profileId, String item, float cost, int score, List<ExpenseSplit> splits) {
        if (cost <= 0) throw new IllegalArgumentException("Cost must be positive");
        if (item == null || item.isBlank()) throw new IllegalArgumentException("Item cannot be null");

        Expense expense = new Expense();
        expense.setId(UUID.randomUUID());
        expense.setHouseholdId(householdId);
        expense.setProfileId(profileId);
        expense.setItem(item);
        expense.setCost(cost);
        expense.setScore(score);

        expenseMapper.insertExpense(expense);

        if (splits != null && !splits.isEmpty()) {
            int numProfiles = splits.size();
            float splitCost = cost / numProfiles;

            for (ExpenseSplit split : splits) {
                split.setExpenseId(expense.getId());
                split.setAmount(splitCost); 
                expenseSplitMapper.insert(split);
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
        expenseMapper.deleteExpense(expenseId);
    }

    public List<ExpenseSplit> getSplits(UUID expenseId) {
        return expenseSplitMapper.getSplitsByExpense(expenseId);
    }
}