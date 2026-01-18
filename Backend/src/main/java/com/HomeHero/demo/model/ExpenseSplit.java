package com.HomeHero.demo.model;

import java.util.UUID;

public class ExpenseSplit {

    private UUID id;
    private UUID profileId;
    private UUID expenseId;
    private float amount;
    private boolean paid;

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

    public boolean isPaid() {
        return paid;
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

    public void setPaid(boolean paid) {
        this.paid = paid;
    }
}
