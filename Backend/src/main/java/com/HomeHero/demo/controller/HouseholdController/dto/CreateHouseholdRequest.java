package com.HomeHero.demo.controller.HouseholdController.dto;

import java.util.List;

public class CreateHouseholdRequest {
    // Existing DB schema has only `address`, but we keep name for future compatibility.
    private String name;
    private String address;

    // Roommates to invite (search/lookup is handled server-side via profiles.email)
    private List<String> roommateEmails;

    public CreateHouseholdRequest() {}

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

    public List<String> getRoommateEmails() {
        return roommateEmails;
    }

    public void setRoommateEmails(List<String> roommateEmails) {
        this.roommateEmails = roommateEmails;
    }
}

