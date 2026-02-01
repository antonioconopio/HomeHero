package com.HomeHero.demo.model;

import java.time.OffsetDateTime;
import java.util.UUID;

public class Grocery {

    private UUID id;
    private UUID profileId;
    private String groceryName;
    private float groceryCost;
    private OffsetDateTime createdAt;
    private UUID householdId;

    public Grocery(){}

    public UUID getId() {
        return id;
    }
    public void setId(UUID id) {
        this.id = id;
    }

    public UUID getProfileId() {
        return profileId;
    }
    public void setProfileId(UUID profileId) {
        this.profileId = profileId;
    }

    public String getGroceryName() {
        return groceryName;
    }
    public void setGroceryName(String groceryName) {
        this.groceryName = groceryName;
    }

    public float getGroceryCost() {
        return groceryCost;
    }
    public void setGroceryCost(float groceryCost) {
        this.groceryCost = groceryCost;
    }

    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }
    public void setCreatedAt(OffsetDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public UUID getHouseholdId() {
        return householdId;
    }
    public void setHouseholdId(UUID householdId) {
        this.householdId = householdId;
    }
}
