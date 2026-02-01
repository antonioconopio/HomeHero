package com.HomeHero.demo.controller.ProfileController;

import com.HomeHero.demo.model.HouseholdInvite;
import com.HomeHero.demo.model.Profile;
import com.HomeHero.demo.service.ProfileService;
import com.HomeHero.demo.service.HouseholdInviteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;
import com.HomeHero.demo.util.CurrentUser;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
public class ProfileController {

    private final ProfileService profileService;
    private final HouseholdInviteService householdInviteService;

    @Autowired
    public ProfileController(ProfileService profileService, HouseholdInviteService householdInviteService) {
        this.profileService = profileService;
        this.householdInviteService = householdInviteService;
    }

    @GetMapping(value = "/getProfile", produces = "application/json")
    public Profile getProfile(
            @RequestHeader(value = "X-Profile-Id", required = false) String profileId
    ) {
        UUID id = CurrentUser.resolveProfileId(profileId);
        return profileService.getProfileById(id);
    }

    @GetMapping(value = "/profiles/search", produces = "application/json")
    public List<Profile> searchProfilesByEmail(@RequestParam("email") String email) {
        return profileService.searchProfilesByEmail(email);
    }

    @GetMapping(value = "/my/invites", produces = "application/json")
    public List<HouseholdInvite> getMyInvites(
            @RequestHeader(value = "X-Profile-Id", required = false) String profileId
    ) {
        UUID id = CurrentUser.resolveProfileId(profileId);
        Profile me = profileService.getProfileById(id);
        String email = me == null ? null : me.getEmail();
        return householdInviteService.getInvitesForProfile(id, email);
    }
}
