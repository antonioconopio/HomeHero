package com.HomeHero.demo.service;

import com.HomeHero.demo.controller.ChoreController.dto.CreateChoreRequest;
import com.HomeHero.demo.model.Chore;
import com.HomeHero.demo.persistance.ChoreMapper;
import com.HomeHero.demo.persistance.HouseholdMapper;
import com.HomeHero.demo.persistance.TaskToHouseholdMapper;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class ChoreService {

    private final ChoreMapper choreMapper;
    private final HouseholdMapper householdMapper;
    private final ObjectMapper objectMapper;
    private final TaskToHouseholdMapper taskToHouseholdMapper;

    // Temporary default creator profile until auth is wired end-to-end
    private static final UUID DEFAULT_PROFILE_ID = UUID.fromString("d3576ad7-6f1f-490a-82a3-3a2de80d186f");

    @Autowired
    public ChoreService(
            ChoreMapper choreMapper,
            HouseholdMapper householdMapper,
            ObjectMapper objectMapper,
            TaskToHouseholdMapper taskToHouseholdMapper
    ) {
        this.choreMapper = choreMapper;
        this.householdMapper = householdMapper;
        this.objectMapper = objectMapper;
        this.taskToHouseholdMapper = taskToHouseholdMapper;
    }

    public List<Chore> getChoresByHouseholdId(UUID householdId) {
        return choreMapper.getChoresByHouseholdId(householdId);
    }

    public Chore createChore(UUID householdId, CreateChoreRequest req) {
        if (householdMapper.getHouseholdById(householdId) == null) {
            throw new IllegalArgumentException("Household not found");
        }
        if (req == null) {
            throw new IllegalArgumentException("Request body is required");
        }
        if (req.getTitle() == null || req.getTitle().trim().isEmpty()) {
            throw new IllegalArgumentException("Chore title is required");
        }

        boolean hasDueAt = req.getDueAt() != null;
        boolean hasRange = req.getStartDate() != null || req.getEndDate() != null;
        if (hasDueAt && hasRange) {
            throw new IllegalArgumentException("Provide either dueAt OR startDate/endDate, not both");
        }
        if (req.getStartDate() != null && req.getEndDate() != null && req.getEndDate().isBefore(req.getStartDate())) {
            throw new IllegalArgumentException("endDate cannot be before startDate");
        }

        Chore c = new Chore();
        c.setId(UUID.randomUUID());
        c.setHouseholdId(householdId);
        c.setTitle(req.getTitle().trim());
        c.setDescription(req.getDescription());
        // Existing schema supports a single due timestamp (task_due_date).
        // If client sends a date-range, we'll store the startDate as midnight UTC-ish via OffsetDateTime parsing is not available here,
        // so for now only accept dueAt; range will be ignored until schema supports it.
        c.setDueAt(req.getDueAt());
        c.setStartDate(req.getStartDate());
        c.setEndDate(req.getEndDate());
        c.setRepeatRule(req.getRepeatRule() == null ? "never" : req.getRepeatRule());
        c.setRotateEnabled(req.getRotateEnabled());
        c.setAssigneeId(req.getAssigneeId());

        // Impact is hardcoded to 5 for now, regardless of request.
        c.setImpact(5);

        try {
            if (req.getRotateWithProfileIds() != null) {
                c.setRotateWithJson(objectMapper.writeValueAsString(req.getRotateWithProfileIds()));
            } else {
                c.setRotateWithJson(null);
            }
        } catch (Exception e) {
            throw new IllegalArgumentException("Invalid rotateWithProfileIds");
        }

        // Insert into existing `task` table
        choreMapper.createChore(c);

        // Link to household via existing `task_to_household`
        UUID linkProfileId = (c.getAssigneeId() != null) ? c.getAssigneeId() : DEFAULT_PROFILE_ID;
        taskToHouseholdMapper.linkTaskToHousehold(UUID.randomUUID(), householdId, c.getId(), linkProfileId);

        // Return canonical view
        Chore out = choreMapper.getChoreById(c.getId());
        if (out != null) {
            out.setHouseholdId(householdId);
        }
        return out;
    }
}

