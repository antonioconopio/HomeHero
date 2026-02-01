package com.HomeHero.demo.model;

import java.time.OffsetDateTime;
import java.util.UUID;

public class GroceryToHousehold {
    private UUID id;
    private OffsetDateTime  created_at;
    private UUID household_id;
    private UUID grocery_id;
    private UUID profile_id;

    public GroceryToHousehold(){}

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public OffsetDateTime getCreatedAt() {
        return created_at;
    }

    public void setCreatedAt(OffsetDateTime created_at) {
        this.created_at = created_at;
    }

    public UUID getHouseholdId() {
        return household_id;
    }

    public void setHouseholdId(UUID household_id) {
        this.household_id = household_id;
    }

    public UUID getGroceryId() {
        return grocery_id;
    }

    public void setGroceryId(UUID grocery_id) {
        this.grocery_id = grocery_id;
    }

    public UUID getProfileId() {
        return profile_id;
    }

    public void setProfileId(UUID profile_id) {
        this.profile_id = profile_id;
    }
}
