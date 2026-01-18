package com.HomeHero.demo.dto;

import com.HomeHero.demo.model.Expense;
import com.HomeHero.demo.model.ExpenseSplit;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

public class ExpenseWithSplitsResponse {
    private UUID id;
    private UUID householdId;
    private UUID profileId;
    private String item;
    private float cost;
    private int score;
    private OffsetDateTime createdAt;
    private List<ExpenseSplit> splits;

    public ExpenseWithSplitsResponse() {}

    public ExpenseWithSplitsResponse(Expense expense, List<ExpenseSplit> splits) {
        this.id = expense.getId();
        this.householdId = expense.getHouseholdId();
        this.profileId = expense.getProfileId();
        this.item = expense.getItem();
        this.cost = expense.getCost();
        this.score = expense.getScore();
        this.createdAt = expense.getCreatedAt();
        this.splits = splits;
    }

    // Getters and Setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getHouseholdId() { return householdId; }
    public void setHouseholdId(UUID householdId) { this.householdId = householdId; }

    public UUID getProfileId() { return profileId; }
    public void setProfileId(UUID profileId) { this.profileId = profileId; }

    public String getItem() { return item; }
    public void setItem(String item) { this.item = item; }

    public float getCost() { return cost; }
    public void setCost(float cost) { this.cost = cost; }

    public int getScore() { return score; }
    public void setScore(int score) { this.score = score; }

    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }

    public List<ExpenseSplit> getSplits() { return splits; }
    public void setSplits(List<ExpenseSplit> splits) { this.splits = splits; }
}
