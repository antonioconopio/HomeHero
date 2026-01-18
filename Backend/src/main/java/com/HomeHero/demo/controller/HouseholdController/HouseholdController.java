package com.HomeHero.demo.controller.HouseholdController;

import com.HomeHero.demo.controller.HouseholdController.dto.AddHouseholdMemberRequest;
import com.HomeHero.demo.controller.HouseholdController.dto.CreateHouseholdRequest;
import com.HomeHero.demo.controller.HouseholdController.dto.InviteToHouseholdRequest;
import com.HomeHero.demo.controller.HouseholdController.dto.JoinHouseholdRequest;
import com.HomeHero.demo.model.Household;
import com.HomeHero.demo.model.Profile;
import com.HomeHero.demo.service.HouseholdInviteService;
import com.HomeHero.demo.service.HouseholdService;
import com.HomeHero.demo.util.CurrentUser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
public class HouseholdController {

    private final HouseholdService householdService;
    private final HouseholdInviteService householdInviteService;

    @Autowired
    public HouseholdController(HouseholdService householdService, HouseholdInviteService householdInviteService) {
        this.householdService = householdService;
        this.householdInviteService = householdInviteService;
    }

    @GetMapping(value = "/households", produces = "application/json")
    public List<Household> getHouseholds() {
        return householdService.getAllHouseholds();
    }

    @GetMapping(value = "/my/households", produces = "application/json")
    public List<Household> getMyHouseholds(
            @RequestHeader(value = "X-Profile-Id", required = false) String profileId
    ) {
        UUID id = CurrentUser.resolveProfileId(profileId);
        return householdService.getHouseholdsForProfile(id);
    }

    @GetMapping(value = "/households/{householdId}", produces = "application/json")
    public Household getHousehold(@PathVariable UUID householdId) {
        Household h = householdService.getHouseholdById(householdId);
        if (h == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Household not found");
        }
        return h;
    }

    @PostMapping(value = "/households", consumes = "application/json", produces = "application/json")
    public Household createHousehold(
            @RequestHeader(value = "X-Profile-Id", required = false) String profileId,
            @RequestBody CreateHouseholdRequest req
    ) {
        try {
            UUID id = CurrentUser.resolveProfileId(profileId);
            return householdService.createHouseholdAndInvite(
                    id,
                    req == null ? null : req.getName(),
                    req == null ? null : req.getAddress(),
                    req == null ? null : req.getRoommateEmails()
            );
        } catch (IllegalArgumentException e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, e.getMessage());
        }
    }

    @PostMapping(value = "/households/join", consumes = "application/json", produces = "application/json")
    public Household joinHousehold(
            @RequestHeader(value = "X-Profile-Id", required = false) String profileId,
            @RequestBody JoinHouseholdRequest req
    ) {
        try {
            UUID id = CurrentUser.resolveProfileId(profileId);
            return householdService.joinHouseholdByHomeCode(id, req == null ? null : req.getHomeCode());
        } catch (IllegalArgumentException e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, e.getMessage());
        }
    }

    @GetMapping(value = "/households/{householdId}/members", produces = "application/json")
    public List<Profile> getMembers(@PathVariable UUID householdId) {
        return householdService.getMembers(householdId);
    }

    @PostMapping(value = "/households/{householdId}/members", consumes = "application/json")
    public void addMember(@PathVariable UUID householdId, @RequestBody AddHouseholdMemberRequest req) {
        if (req == null || req.getProfileId() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "profileId is required");
        }
        try {
            householdService.addMember(householdId, req.getProfileId());
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Could not add member");
        }
    }

    @PostMapping(value = "/households/{householdId}/invite", consumes = "application/json")
    public void inviteToHousehold(
            @PathVariable UUID householdId,
            @RequestHeader(value = "X-Profile-Id", required = false) String profileId,
            @RequestBody InviteToHouseholdRequest req
    ) {
        if (req == null || req.getEmail() == null || req.getEmail().trim().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "email is required");
        }
        try {
            UUID inviterId = CurrentUser.resolveProfileId(profileId);
            householdInviteService.inviteByEmail(householdId, inviterId, req.getEmail());
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Could not send invite: " + e.getMessage());
        }
    }

    @PostMapping(value = "/households/{householdId}/leave")
    public void leaveHousehold(
            @PathVariable UUID householdId,
            @RequestHeader(value = "X-Profile-Id", required = false) String profileIdHeader
    ) {
        try {
            UUID profileId = CurrentUser.resolveProfileId(profileIdHeader);
            householdService.leaveHousehold(householdId, profileId);
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Could not leave household: " + e.getMessage());
        }
    }
}

