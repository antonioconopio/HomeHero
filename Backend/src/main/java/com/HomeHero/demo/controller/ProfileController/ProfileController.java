package com.HomeHero.demo.controller.ProfileController;

import com.HomeHero.demo.model.HouseholdInvite;
import com.HomeHero.demo.model.Profile;
import com.HomeHero.demo.service.HouseholdInviteService;
import com.HomeHero.demo.service.ProfileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.HomeHero.demo.util.CurrentUser;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
public class ProfileController {
    //private final AuthService authService;
    private final ProfileService profileService;
    private final HouseholdInviteService householdInviteService;

    @Autowired
    public ProfileController(ProfileService profileService, HouseholdInviteService householdInviteService) {
        this.profileService = profileService;
        this.householdInviteService = householdInviteService;
    }

    @GetMapping(value = "/getProfile", produces = "application/json")
    public Profile getProfile() {

//        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
//            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing Bearer token");
//        }
//
//        String token = authHeader.replace("Bearer ", "");
        //String userId = authService.getUserIdFromToken(token);
//        return profileService.getProfileById(UUID.fromString("userId"));
        return profileService.getProfileById(CurrentUser.PROFILE_ID);
    }

    @GetMapping(value = "/profiles/search", produces = "application/json")
    public List<Profile> searchProfilesByEmail(@RequestParam("email") String email) {
        return profileService.searchProfilesByEmail(email);
    }

    @GetMapping(value = "/my/invites", produces = "application/json")
    public List<HouseholdInvite> getMyInvites() {
        Profile me = profileService.getProfileById(CurrentUser.PROFILE_ID);
        String email = me == null ? null : me.getEmail();
        return householdInviteService.getInvitesForProfile(CurrentUser.PROFILE_ID, email);
    }
}
