package com.HomeHero.demo.service;

import com.HomeHero.demo.model.HouseholdInvite;
import com.HomeHero.demo.model.Profile;
import com.HomeHero.demo.persistance.HouseholdInviteMapper;
import com.HomeHero.demo.persistance.HouseholdMemberMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class HouseholdInviteService {

    private final HouseholdInviteMapper inviteMapper;
    private final HouseholdMemberMapper memberMapper;
    private final ProfileService profileService;

    @Autowired
    public HouseholdInviteService(
            HouseholdInviteMapper inviteMapper,
            HouseholdMemberMapper memberMapper,
            ProfileService profileService
    ) {
        this.inviteMapper = inviteMapper;
        this.memberMapper = memberMapper;
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

    public HouseholdInvite getInviteById(UUID inviteId) {
        return inviteMapper.getInviteById(inviteId);
    }

    @Transactional
    public void acceptInvite(UUID inviteId, UUID acceptingProfileId) {
        HouseholdInvite invite = inviteMapper.getInviteById(inviteId);
        if (invite == null) {
            throw new IllegalArgumentException("Invite not found");
        }

        // Verify the accepting user is the invitee
        Profile acceptor = profileService.getProfileById(acceptingProfileId);
        if (acceptor == null) {
            throw new IllegalArgumentException("Profile not found");
        }

        boolean isInvitee = (invite.getInviteeProfileId() != null && invite.getInviteeProfileId().equals(acceptingProfileId))
                || (invite.getInviteeEmail() != null && acceptor.getEmail() != null
                    && invite.getInviteeEmail().equalsIgnoreCase(acceptor.getEmail()));

        if (!isInvitee) {
            throw new IllegalArgumentException("You are not authorized to accept this invite");
        }

        // Update invite status
        inviteMapper.updateInviteStatus(inviteId, "accepted");

        // Add user to household
        memberMapper.addMember(UUID.randomUUID(), invite.getHouseholdId(), acceptingProfileId);
    }

    public void declineInvite(UUID inviteId, UUID decliningProfileId) {
        HouseholdInvite invite = inviteMapper.getInviteById(inviteId);
        if (invite == null) {
            throw new IllegalArgumentException("Invite not found");
        }

        // Verify the declining user is the invitee
        Profile decliner = profileService.getProfileById(decliningProfileId);
        if (decliner == null) {
            throw new IllegalArgumentException("Profile not found");
        }

        boolean isInvitee = (invite.getInviteeProfileId() != null && invite.getInviteeProfileId().equals(decliningProfileId))
                || (invite.getInviteeEmail() != null && decliner.getEmail() != null
                    && invite.getInviteeEmail().equalsIgnoreCase(decliner.getEmail()));

        if (!isInvitee) {
            throw new IllegalArgumentException("You are not authorized to decline this invite");
        }

        // Update invite status
        inviteMapper.updateInviteStatus(inviteId, "declined");
    }
}

