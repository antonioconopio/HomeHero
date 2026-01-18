package com.HomeHero.demo.controller.ExpenseController;

import com.HomeHero.demo.dto.CreateExpenseSplitRequest;
import com.HomeHero.demo.dto.UpdateExpenseRequest;
import com.HomeHero.demo.model.Expense;
import com.HomeHero.demo.model.ExpenseSplit;
import com.HomeHero.demo.service.ExpenseService;
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

    @Autowired
    public ExpenseController(ExpenseService expenseService) {
        this.expenseService = expenseService;
    }

    @GetMapping("/{expenseId}")
    public Expense getExpenseById(@PathVariable UUID expenseId) {
        return expenseService.getExpenseById(expenseId);
    }

    @GetMapping("/households/{householdId}")
    public List<Expense> getExpensesByHousehold(@PathVariable UUID householdId) {
        return expenseService.getExpensesByHouseholdId(householdId);
    }

    @PostMapping("/households/{householdId}/expenses")
    public Expense createExpense(@PathVariable UUID householdId, @RequestBody CreateExpenseSplitRequest request) {
        
        List<ExpenseSplit> splits = null;

        if (request.getProfileIds() != null && !request.getProfileIds().isEmpty()) {
            splits = request.getProfileIds().stream().map(profileId -> {
                ExpenseSplit split = new ExpenseSplit();
                split.setProfileId(profileId);
                return split;
            }).toList();
        }

        return expenseService.createExpense(
            householdId,
            request.getProfileId(),
            request.getItem(),
            request.getCost(),
            request.getScore(),
            splits
        );
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

}
