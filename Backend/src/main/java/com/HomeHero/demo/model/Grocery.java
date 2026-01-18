package com.HomeHero.demo.model;

import java.sql.Time;
import java.sql.Timestamp;
import java.time.OffsetDateTime;
import java.util.UUID;

public class Grocery {
    private UUID id;
    private UUID profile_id;
    private String grocery_name;
    private float grocery_cost;
    private OffsetDateTime created_at;

    public Grocery(){}

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public UUID getProfileId() {
        return profile_id;
    }

    public void setProfileId(UUID profile_id) {
        this.profile_id = profile_id;
    }

    public String getGroceryName() {
        return grocery_name;
    }

    public void setGroceryName(String grocery_name) {
        this.grocery_name = grocery_name;
    }

    public float getGroceryCost() {
        return grocery_cost;
    }

    public void setGroceryCost(float grocery_cost) {
        this.grocery_cost = grocery_cost;
    }

    public OffsetDateTime getCreatedAt() {
        return created_at;
    }

    public void setCreated_at(OffsetDateTime created_at) {
        this.created_at = created_at;
    }

}
