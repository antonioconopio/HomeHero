package com.HomeHero.demo.model;

import java.time.OffsetDateTime;
import java.util.UUID;

public class HouseholdInvite {
    private UUID id;
    private UUID householdId;
    private UUID inviterProfileId;
    private UUID inviteeProfileId;
    private String inviteeEmail;
    private String status; // pending, accepted, declined
    private OffsetDateTime createdAt;

    // Enriched (optional) for UI
    private String householdAddress;

    public HouseholdInvite() {}

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

    public UUID getInviterProfileId() {
        return inviterProfileId;
    }

    public void setInviterProfileId(UUID inviterProfileId) {
        this.inviterProfileId = inviterProfileId;
    }

    public UUID getInviteeProfileId() {
        return inviteeProfileId;
    }

    public void setInviteeProfileId(UUID inviteeProfileId) {
        this.inviteeProfileId = inviteeProfileId;
    }

    public String getInviteeEmail() {
        return inviteeEmail;
    }

    public void setInviteeEmail(String inviteeEmail) {
        this.inviteeEmail = inviteeEmail;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(OffsetDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public String getHouseholdAddress() {
        return householdAddress;
    }

    public void setHouseholdAddress(String householdAddress) {
        this.householdAddress = householdAddress;
    }
}

