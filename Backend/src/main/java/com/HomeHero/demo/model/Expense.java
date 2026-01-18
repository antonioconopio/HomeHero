package com.HomeHero.demo.model;

import java.time.OffsetDateTime;
import java.util.UUID;

public class Expense {
    
    private UUID id;
    private UUID householdId;
    private UUID profileId;
    private String item;
    private float cost;
    private int score;
    private OffsetDateTime createdAt;

    // Getters and setters
    public UUID getId() { 
        return id; 
    }

    public void setId(UUID id) { 
        this.id = id; 
    }

    public UUID getHouseholdId() { 
        return householdId; 
    }

    public void setHouseholdId(UUID householdId) { 
        this.householdId = householdId; 
    }

    public UUID getProfileId() { 
        return profileId; 
    }

    public void setProfileId(UUID profileId) { 
        this.profileId = profileId; 
    }

    public String getItem() { 
        return item; 
    }

    public void setItem(String item) { 
        this.item = item; 
    }

    public float getCost() { 
        return cost; 
    }

    public void setCost(float cost) { 
        this.cost = cost; 
    }

    public int getScore() { 
        return score; 
    }

    public void setScore(int score) { 
        this.score = score; 
    }

    public OffsetDateTime getCreatedAt() { 
        return createdAt; 
    }

    public void setCreatedAt(OffsetDateTime createdAt) { 
        this.createdAt = createdAt; 
    }
}
