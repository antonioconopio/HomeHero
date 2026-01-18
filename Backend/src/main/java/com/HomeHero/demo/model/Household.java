package com.HomeHero.demo.model;

import java.time.OffsetDateTime;
import java.util.UUID;

public class Household {
    private UUID id;
    private String name;
    private String address;
    private String homeCode; // DB column: home_code
    private int score;
    private OffsetDateTime createdAt;

    public Household() {}

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getHomeCode() {
        return homeCode;
    }

    public void setHomeCode(String homeCode) {
        this.homeCode = homeCode;
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

