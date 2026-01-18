package com.HomeHero.demo.service;

import com.HomeHero.demo.model.HouseholdInvite;
import com.HomeHero.demo.model.Profile;
import com.HomeHero.demo.persistance.HouseholdInviteMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class HouseholdInviteService {

    private final HouseholdInviteMapper inviteMapper;
    private final ProfileService profileService;

    @Autowired
    public HouseholdInviteService(HouseholdInviteMapper inviteMapper, ProfileService profileService) {
        this.inviteMapper = inviteMapper;
        this.profileService = profileService;
    }

    public void inviteByEmail(UUID householdId, UUID inviterProfileId, String email) {
        if (email == null) return;
        String trimmed = email.trim();
        if (trimmed.isEmpty()) return;

        Profile invitee = profileService.getProfileByEmail(trimmed);

        HouseholdInvite invite = new HouseholdInvite();
        invite.setId(UUID.randomUUID());
        invite.setHouseholdId(householdId);
        invite.setInviterProfileId(inviterProfileId);
        invite.setInviteeProfileId(invitee == null ? null : invitee.getId());
        invite.setInviteeEmail(trimmed);
        invite.setStatus("pending");

        inviteMapper.createInvite(invite);
    }

    public List<HouseholdInvite> getInvitesForProfile(UUID profileId, String email) {
        return inviteMapper.getInvitesForProfile(profileId, email);
    }
}

