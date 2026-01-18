package com.HomeHero.demo.controller.ChoreController;

import com.HomeHero.demo.controller.ChoreController.dto.CreateChoreRequest;
import com.HomeHero.demo.model.Chore;
import com.HomeHero.demo.service.ChoreService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
public class ChoreController {

    private final ChoreService choreService;

    @Autowired
    public ChoreController(ChoreService choreService) {
        this.choreService = choreService;
    }

    @GetMapping(value = "/households/{householdId}/chores", produces = "application/json")
    public List<Chore> getChores(@PathVariable UUID householdId) {
        return choreService.getChoresByHouseholdId(householdId);
    }

    @PostMapping(value = "/households/{householdId}/chores", consumes = "application/json", produces = "application/json")
    public Chore createChore(@PathVariable UUID householdId, @RequestBody CreateChoreRequest req) {
        try {
            return choreService.createChore(householdId, req);
        } catch (IllegalArgumentException e) {
            String msg = e.getMessage() == null ? "Invalid request" : e.getMessage();
            HttpStatus status = msg.toLowerCase().contains("not found") ? HttpStatus.NOT_FOUND : HttpStatus.BAD_REQUEST;
            throw new ResponseStatusException(status, msg);
        }
    }
}

