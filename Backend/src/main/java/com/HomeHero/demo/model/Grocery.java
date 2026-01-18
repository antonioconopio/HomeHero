package com.HomeHero.demo.model;

import java.time.OffsetDateTime;
import java.util.UUID;

public class Grocery {
    private UUID id;
    private UUID profile_id;
    private String grocery_name;
    private float grocery_cost;
    private OffsetDateTime created_at;
    private UUID household_id;

    public Grocery(){}

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getProfile_id() { return profile_id; }
    public void setProfile_id(UUID profile_id) { this.profile_id = profile_id; }

    public String getGrocery_name() { return grocery_name; }
    public void setGrocery_name(String grocery_name) { this.grocery_name = grocery_name; }

    public float getGrocery_cost() { return grocery_cost; }
    public void setGrocery_cost(float grocery_cost) { this.grocery_cost = grocery_cost; }

    public OffsetDateTime getCreated_at() { return created_at; }
    public void setCreated_at(OffsetDateTime created_at) { this.created_at = created_at; }

    public UUID getHousehold_id() { return household_id; }
    public void setHousehold_id(UUID household_id) { this.household_id = household_id; }
}
