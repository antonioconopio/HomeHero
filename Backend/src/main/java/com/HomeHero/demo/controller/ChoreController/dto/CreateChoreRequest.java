package com.HomeHero.demo.controller.ChoreController.dto;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

public class CreateChoreRequest {
    private String title;
    private String description;

    // Either dueAt OR (startDate/endDate)
    private OffsetDateTime dueAt;
    private LocalDate startDate;
    private LocalDate endDate;

    private String repeatRule; // never, hourly, daily, weekdays, weekends, weekly, biweekly, monthly, every 3 months...

    private Boolean rotateEnabled;
    private List<UUID> rotateWithProfileIds;

    private UUID assigneeId;

    public CreateChoreRequest() {}

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

    public List<UUID> getRotateWithProfileIds() {
        return rotateWithProfileIds;
    }

    public void setRotateWithProfileIds(List<UUID> rotateWithProfileIds) {
        this.rotateWithProfileIds = rotateWithProfileIds;
    }

    public UUID getAssigneeId() {
        return assigneeId;
    }

    public void setAssigneeId(UUID assigneeId) {
        this.assigneeId = assigneeId;
    }
}

