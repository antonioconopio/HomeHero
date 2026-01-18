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

    public Expense() {}

    public UUID getId() {
        return id;
    }

    public UUID getHouseholdId() {
        return householdId;
    }

    public UUID getProfileId() {
        return profileId;
    }

    public String getItem() {
        return item;
    }

    public float getCost() {
        return cost;
    }

    public int getScore() {
        return score;
    }

    public OffsetDateTime getCreatedAt() { 
        return createdAt; 
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public void setHouseholdId(UUID householdId) {
        this.householdId = householdId;
    }

    public void setProfileId(UUID profileId) {
        this.profileId = profileId;
    }

    public void setItem(String item) {
        this.item = item;
    }

    public void setCost(float cost) {
        this.cost = cost;
    }

    public void setScore(int score) {
        this.score = score;
    }

    public void setCreatedAt(OffsetDateTime createdAt) { 
        this.createdAt = createdAt; 
    }
}
