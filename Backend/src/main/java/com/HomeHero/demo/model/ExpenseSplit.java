package com.HomeHero.demo.model;

import java.util.UUID;

public class ExpenseSplit {

    private UUID id;
    private UUID profileId;
    private UUID expenseId;
    private float amount;

    public ExpenseSplit() {}

    public UUID getId() {
        return id;
    }

    public UUID getProfileId() {
        return profileId;
    }

    public UUID getExpenseId() {
        return expenseId;
    }

    public float getAmount() {
        return amount;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public void setProfileId(UUID profileId) {
        this.profileId = profileId;
    }

    public void setExpenseId(UUID expenseId) {
        this.expenseId = expenseId;
    }

    public void setAmount(float amount) {
        this.amount = amount;
    }
    
}
