package com.HomeHero.demo.controller.ExpenseController;

import com.HomeHero.demo.dto.CreateExpenseSplitRequest;
import com.HomeHero.demo.dto.ExpenseWithSplitsResponse;
import com.HomeHero.demo.dto.UpdateExpenseRequest;
import com.HomeHero.demo.model.Expense;
import com.HomeHero.demo.model.ExpenseSplit;
import com.HomeHero.demo.service.ExpenseService;
import com.HomeHero.demo.util.CurrentUser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/expenses")
public class ExpenseController {
    
    private final ExpenseService expenseService;
    private final CurrentUser currentUser;

    @Autowired
    public ExpenseController(ExpenseService expenseService, CurrentUser currentUser) {
        this.expenseService = expenseService;
        this.currentUser = currentUser;
    }

    @GetMapping("/{expenseId}")
    public ExpenseWithSplitsResponse getExpenseById(@PathVariable UUID expenseId) {
        Expense expense = expenseService.getExpenseById(expenseId);
        List<ExpenseSplit> splits = expenseService.getSplits(expenseId);
        return new ExpenseWithSplitsResponse(expense, splits);
    }

    @GetMapping("/households/{householdId}")
    public List<ExpenseWithSplitsResponse> getExpensesByHousehold(@PathVariable UUID householdId) {
        List<Expense> expenses = expenseService.getExpensesByHouseholdId(householdId);
        return expenses.stream().map(expense -> {
            List<ExpenseSplit> splits = expenseService.getSplits(expense.getId());
            return new ExpenseWithSplitsResponse(expense, splits);
        }).toList();
    }

    @GetMapping("/households/{householdId}/my-splits")
    public List<ExpenseSplit> getMySplitsForHousehold(@PathVariable UUID householdId) {
        UUID profileId = currentUser.getProfileId();
        return expenseService.getSplitsByProfileAndHousehold(profileId, householdId);
    }

    @GetMapping("/households/{householdId}/monthly-total")
    public float getMonthlyTotal(@PathVariable UUID householdId) {
        return expenseService.getMonthlyTotalByHousehold(householdId);
    }

    @PostMapping("/households/{householdId}/expenses")
    public ExpenseWithSplitsResponse createExpense(@PathVariable UUID householdId, @RequestBody CreateExpenseSplitRequest request) {
        
        List<ExpenseSplit> splits = null;

        if (request.getProfileIds() != null && !request.getProfileIds().isEmpty()) {
            splits = request.getProfileIds().stream().map(profileId -> {
                ExpenseSplit split = new ExpenseSplit();
                split.setProfileId(profileId);
                return split;
            }).toList();
        }

        Expense expense = expenseService.createExpense(
            householdId,
            request.getProfileId(),
            request.getItem(),
            request.getCost(),
            request.getScore(),
            splits
        );

        List<ExpenseSplit> createdSplits = expenseService.getSplits(expense.getId());
        return new ExpenseWithSplitsResponse(expense, createdSplits);
    }

    @PutMapping("/{expenseId}")
    public void updateExpense(@PathVariable UUID expenseId, @RequestBody UpdateExpenseRequest request) {
        expenseService.updateExpense(
            expenseId,
            request.getItem(),
            request.getCost()
        );
    }

    @DeleteMapping("/{expenseId}")
    public void removeExpense(@PathVariable UUID expenseId) {
        expenseService.removeExpense(expenseId);
    }

    @PostMapping("/splits/{splitId}/mark-paid")
    public void markSplitAsPaid(@PathVariable UUID splitId) {
        expenseService.markSplitAsPaid(splitId);
    }

    @PostMapping("/splits/{splitId}/mark-unpaid")
    public void markSplitAsUnpaid(@PathVariable UUID splitId) {
        expenseService.markSplitAsUnpaid(splitId);
    }
}
