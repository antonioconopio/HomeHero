package com.HomeHero.demo.service;

import com.HomeHero.demo.controller.ChoreController.dto.CreateChoreRequest;
import com.HomeHero.demo.model.Chore;
import com.HomeHero.demo.model.Profile;
import com.HomeHero.demo.persistance.ChoreMapper;
import com.HomeHero.demo.persistance.HouseholdMapper;
import com.HomeHero.demo.persistance.HouseholdMemberMapper;
import com.HomeHero.demo.persistance.ProfileMapper;
import com.HomeHero.demo.persistance.TaskToHouseholdMapper;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.List;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

@Service
public class ChoreService {

    private final ChoreMapper choreMapper;
    private final HouseholdMapper householdMapper;
    private final HouseholdMemberMapper householdMemberMapper;
    private final ProfileMapper profileMapper;
    private final ObjectMapper objectMapper;
    private final TaskToHouseholdMapper taskToHouseholdMapper;
    private final WebClient webClient;
    private final String openRouterApiKey;

    // Temporary default creator profile until auth is wired end-to-end
    private static final UUID DEFAULT_PROFILE_ID = UUID.fromString("d3576ad7-6f1f-490a-82a3-3a2de80d186f");
    private static final String OPENROUTER_API_URL = "https://openrouter.ai/api/v1/chat/completions";

    @Autowired
    public ChoreService(
            ChoreMapper choreMapper,
            HouseholdMapper householdMapper,
            HouseholdMemberMapper householdMemberMapper,
            ProfileMapper profileMapper,
            ObjectMapper objectMapper,
            TaskToHouseholdMapper taskToHouseholdMapper,
            WebClient.Builder webClientBuilder,
            @Value("${openrouter.api.key}") String openRouterApiKey
    ) {
        this.choreMapper = choreMapper;
        this.householdMapper = householdMapper;
        this.householdMemberMapper = householdMemberMapper;
        this.profileMapper = profileMapper;
        this.objectMapper = objectMapper;
        this.taskToHouseholdMapper = taskToHouseholdMapper;
        this.webClient = webClientBuilder.build();
        this.openRouterApiKey = openRouterApiKey;
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
        c.setRotateEnabled(Boolean.TRUE.equals(req.getRotateEnabled()));

        // Impact is calculated using OpenRouter API
        String prompt = "You are an expert task management system that assigns point values to household chores based on their difficulty and time required. Respond with a single integer from 1 to 10. No extra text. Chore: %s%s".formatted(
                c.getTitle(),
                c.getDescription() != null ? " - " + c.getDescription() : ""
        );

        int impact = getChoreImpactFromOpenRouter(prompt);
        c.setImpact(impact);

        try {
            if (req.getRotateWithProfileIds() != null) {
                c.setRotateWithJson(objectMapper.writeValueAsString(req.getRotateWithProfileIds()));
            } else {
                c.setRotateWithJson(null);
            }
        } catch (Exception e) {
            throw new IllegalArgumentException("Invalid rotateWithProfileIds");
        }

        // Assignment: no manual assignee input from client.
        // If cycling is enabled (repeatRule != never + rotateEnabled), assign in a round-robin cycle
        // through the selected roommates (or all roommates if none specified).
        // Otherwise assign deterministically to the first household member (stable, non-random).
        UUID chosenAssigneeId = pickCycledAssignee(householdId, req);
        c.setAssigneeId(chosenAssigneeId);

        // Insert into existing `task` table
        choreMapper.createChore(c);

        // Link to household via existing `task_to_household`
        UUID linkProfileId = (chosenAssigneeId != null) ? chosenAssigneeId : DEFAULT_PROFILE_ID;
        taskToHouseholdMapper.linkTaskToHousehold(UUID.randomUUID(), householdId, c.getId(), linkProfileId);

        // Return canonical view
        return choreMapper.getChoreByHouseholdAndTaskId(householdId, c.getId());
    }

    public void completeChore(UUID householdId, UUID choreId) {
        if (householdMapper.getHouseholdById(householdId) == null) {
            throw new IllegalArgumentException("Household not found");
        }
        if (choreId == null) {
            throw new IllegalArgumentException("Chore id is required");
        }

        // Validate the chore is currently linked to this household and capture a profile id for scoring fallback.
        UUID linkedProfileId = taskToHouseholdMapper.getLinkedProfileId(householdId, choreId);
        if (linkedProfileId == null) {
            throw new IllegalArgumentException("Chore not found");
        }

        // Load chore details for scoring.
        Chore chore = choreMapper.getChoreById(choreId);
        if (chore == null) {
            throw new IllegalArgumentException("Chore not found");
        }

        int deleted = taskToHouseholdMapper.unlinkTaskFromHousehold(householdId, choreId);
        if (deleted <= 0) {
            throw new IllegalArgumentException("Chore not found");
        }

        // Update user score by the chore's impact (fixed amount per task).
        int delta = chore.getImpact();
        if (delta > 0) {
            profileMapper.incrementUserScore(linkedProfileId, delta);
        }
    }

    private UUID pickCycledAssignee(UUID householdId, CreateChoreRequest req) {
        List<Profile> members = householdMemberMapper.getMembers(householdId);
        if (members == null || members.isEmpty()) {
            throw new IllegalArgumentException("No household members found to assign this chore");
        }

        String repeatRule = (req.getRepeatRule() == null) ? "never" : req.getRepeatRule().trim();
        boolean rotationEligible = !repeatRule.equalsIgnoreCase("never");
        boolean cycleEnabled = rotationEligible && Boolean.TRUE.equals(req.getRotateEnabled());

        // Stable ordering: members are already ordered by first_name/last_name in SQL.
        List<UUID> orderedAll = new ArrayList<>();
        for (Profile p : members) {
            if (p != null && p.getId() != null) {
                orderedAll.add(p.getId());
            }
        }
        if (orderedAll.isEmpty()) {
            throw new IllegalArgumentException("No household members found to assign this chore");
        }

        // Non-repeating chore: user must pick a responsible roommate.
        if (!rotationEligible) {
            UUID requested = req.getAssigneeId();
            if (requested == null) {
                throw new IllegalArgumentException("Responsible roommate is required when repeat is set to never");
            }
            if (!orderedAll.contains(requested)) {
                throw new IllegalArgumentException("Selected responsible roommate is not a member of this household");
            }
            return requested;
        }

        if (!cycleEnabled) {
            return orderedAll.get(0);
        }

        List<UUID> candidatesOrdered = new ArrayList<>();
        if (req.getRotateWithProfileIds() != null && !req.getRotateWithProfileIds().isEmpty()) {
            Set<UUID> allow = new HashSet<>(req.getRotateWithProfileIds());
            for (UUID id : orderedAll) {
                if (allow.contains(id)) {
                    candidatesOrdered.add(id);
                }
            }
        } else {
            candidatesOrdered.addAll(orderedAll);
        }

        if (candidatesOrdered.isEmpty()) {
            throw new IllegalArgumentException("No eligible roommates found for cycling");
        }

        // Round-robin index based on how many matching chores already exist in this household.
        // This gives a stable cycle without needing new DB columns.
        String title = (req.getTitle() == null) ? "" : req.getTitle().trim();
        List<Chore> existing = choreMapper.getChoresByHouseholdId(householdId);
        Set<UUID> candidateSet = new HashSet<>(candidatesOrdered);
        int alreadyAssignedCount = 0;
        if (existing != null) {
            for (Chore ch : existing) {
                if (ch == null) continue;
                if (ch.getTitle() == null) continue;
                if (!ch.getTitle().trim().equalsIgnoreCase(title)) continue;
                UUID aid = ch.getAssigneeId();
                if (aid != null && candidateSet.contains(aid)) {
                    alreadyAssignedCount++;
                }
            }
        }

        int idx = alreadyAssignedCount % candidatesOrdered.size();
        return candidatesOrdered.get(idx);
    }

    private int getChoreImpactFromOpenRouter(String prompt) {
        try {
            OpenRouterRequest request = new OpenRouterRequest(
                    "google/gemini-2.5-flash",
                List.of(new Message("user", prompt)),
                1
            );

            OpenRouterResponse response = webClient.post()
                    .uri(OPENROUTER_API_URL)
                    .header("Authorization", "Bearer " + openRouterApiKey)
                    .header("HTTP-Referer", "https://homehero.app")
                    .header("X-Title", "HomeHero")
                    .bodyValue(request)
                    .retrieve()
                    .bodyToMono(OpenRouterResponse.class)
                    .block();

            if (response != null && response.getChoices() != null && !response.getChoices().isEmpty()) {
                String content = response.getChoices().get(0).getMessage().getContent().trim();
                return Integer.parseInt(content);
            }
            return 5; // Default fallback
        } catch (Exception e) {
            System.err.println("Error calling OpenRouter API: " + e.getMessage());
            return 5; // Default fallback
        }
    }

    // Helper classes for OpenRouter API
    public static class OpenRouterRequest {
        private String model;
        private List<Message> messages;
        private Integer top_p;

        public OpenRouterRequest(String model, List<Message> messages, Integer top_p) {
            this.model = model;
            this.messages = messages;
            this.top_p = top_p;
        }

        public String getModel() { return model; }
        public List<Message> getMessages() { return messages; }
        public Integer getTop_p() { return top_p; }
    }

    public static class Message {
        private String role;
        private String content;

        public Message(String role, String content) {
            this.role = role;
            this.content = content;
        }

        public String getRole() { return role; }
        public String getContent() { return content; }
    }

    public static class OpenRouterResponse {
        private List<Choice> choices;

        public List<Choice> getChoices() { return choices; }
        public void setChoices(List<Choice> choices) { this.choices = choices; }
    }

    public static class Choice {
        private Message message;

        public Message getMessage() { return message; }
        public void setMessage(Message message) { this.message = message; }
    }
}

