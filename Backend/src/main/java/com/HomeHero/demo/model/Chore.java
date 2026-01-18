package com.HomeHero.demo.model;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

public class Chore {
    private UUID id;
    private UUID householdId;
    private String title;
    private String description;

    // Either dueAt OR (startDate/endDate)
    private OffsetDateTime dueAt;
    private LocalDate startDate;
    private LocalDate endDate;

    private String repeatRule;        // e.g. "daily", "weekly", etc
    private Boolean rotateEnabled;
    private String rotateWithJson;    // JSON array of UUID strings for now

    private UUID assigneeId;          // optional

    // hardcoded to 5 for now
    private int impact;

    private OffsetDateTime createdAt;

    public Chore() {}

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

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public OffsetDateTime getDueAt() {
        return dueAt;
    }

    public void setDueAt(OffsetDateTime dueAt) {
        this.dueAt = dueAt;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }

    public String getRepeatRule() {
        return repeatRule;
    }

    public void setRepeatRule(String repeatRule) {
        this.repeatRule = repeatRule;
    }

    public Boolean getRotateEnabled() {
        return rotateEnabled;
    }

    public void setRotateEnabled(Boolean rotateEnabled) {
        this.rotateEnabled = rotateEnabled;
    }

    public String getRotateWithJson() {
        return rotateWithJson;
    }

    public void setRotateWithJson(String rotateWithJson) {
        this.rotateWithJson = rotateWithJson;
    }

    public UUID getAssigneeId() {
        return assigneeId;
    }

    public void setAssigneeId(UUID assigneeId) {
        this.assigneeId = assigneeId;
    }

    public int getImpact() {
        return impact;
    }

    public void setImpact(int impact) {
        this.impact = impact;
    }

    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(OffsetDateTime createdAt) {
        this.createdAt = createdAt;
    }
}

