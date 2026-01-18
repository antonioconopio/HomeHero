package com.HomeHero.demo.controller.ProfileController;

import com.HomeHero.demo.model.HouseholdInvite;
import com.HomeHero.demo.model.Profile;
import com.HomeHero.demo.service.AuthService;
import com.HomeHero.demo.service.HouseholdInviteService;
import com.HomeHero.demo.service.ProfileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
public class ProfileController {
    //private final AuthService authService;
    private final AuthService authService;
    private final ProfileService profileService;
    private final HouseholdInviteService householdInviteService;

    @Autowired
    public ProfileController(AuthService authService, ProfileService profileService, HouseholdInviteService householdInviteService) {
        this.authService = authService;
        this.profileService = profileService;
        this.householdInviteService = householdInviteService;
    }

    @GetMapping(value = "/getProfile", produces = "application/json")
    public Profile getProfile(@RequestHeader(value = "Authorization", required = false) String authHeader) {

//        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
//            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing Bearer token");
//        }
//
//        String token = authHeader.replace("Bearer ", "");
        //String userId = authService.getUserIdFromToken(token);
//        return profileService.getProfileById(UUID.fromString("userId"));
        UUID profileId = authService.resolveProfileIdOrDefault(authHeader);
        return profileService.getProfileById(profileId);
    }

    @GetMapping(value = "/profiles/search", produces = "application/json")
    public List<Profile> searchProfilesByEmail(@RequestParam("email") String email) {
        return profileService.searchProfilesByEmail(email);
    }

    @GetMapping(value = "/my/invites", produces = "application/json")
    public List<HouseholdInvite> getMyInvites(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        UUID profileId = authService.resolveProfileIdOrDefault(authHeader);
        Profile me = profileService.getProfileById(profileId);
        String email = me == null ? null : me.getEmail();
        return householdInviteService.getInvitesForProfile(profileId, email);
    }
}
