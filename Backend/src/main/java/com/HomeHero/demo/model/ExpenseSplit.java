package com.HomeHero.demo.model;

import java.util.UUID;

public class ExpenseSplit {

    private UUID id;
    private UUID expenseId; 
    private UUID profileId; 
    private float amount;

    public UUID getId() { 
        return id; 
    }

    public void setId(UUID id) { 
        this.id = id; 
    }

    public UUID getExpenseId() { 
        return expenseId; 
    }

    public void setExpenseId(UUID expenseId) { 
        this.expenseId = expenseId; 
    }

    public UUID getProfileId() { 
        return profileId; 
    }

    public void setProfileId(UUID profileId) { 
        this.profileId = profileId; 
    }

    public float getAmount() { 
        return amount; 
    }

    public void setAmount(float amount) { 
        this.amount = amount; 
    }
}
