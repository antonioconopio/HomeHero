package com.HomeHero.demo.controller.HouseholdController.dto;

import java.util.UUID;

public class AddHouseholdMemberRequest {
    private UUID profileId;

    public AddHouseholdMemberRequest() {}

    public UUID getProfileId() {
        return profileId;
    }

    public void setProfileId(UUID profileId) {
        this.profileId = profileId;
    }
}

