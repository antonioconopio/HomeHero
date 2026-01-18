package com.HomeHero.demo.service;

import com.HomeHero.demo.model.Household;
import com.HomeHero.demo.model.Profile;
import com.HomeHero.demo.persistance.HouseholdMapper;
import com.HomeHero.demo.persistance.HouseholdMemberMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.concurrent.ThreadLocalRandom;
import java.util.List;
import java.util.UUID;

@Service
public class HouseholdService {

    private final HouseholdMapper householdMapper;
    private final HouseholdMemberMapper householdMemberMapper;
    private final HouseholdInviteService inviteService;

    @Autowired
    public HouseholdService(
            HouseholdMapper householdMapper,
            HouseholdMemberMapper householdMemberMapper,
            HouseholdInviteService inviteService
    ) {
        this.householdMapper = householdMapper;
        this.householdMemberMapper = householdMemberMapper;
        this.inviteService = inviteService;
    }

    public List<Household> getAllHouseholds() {
        return householdMapper.getAllHouseholds();
    }

    public Household getHouseholdById(UUID id) {
        return householdMapper.getHouseholdById(id);
    }

    public List<Household> getHouseholdsForProfile(UUID profileId) {
        return householdMapper.getHouseholdsForProfile(profileId);
    }

    public Household createHousehold(String name, String address) {
        // Existing schema only has `address` (no `name` column).
        // We'll store the best available label into `address`.
        String label = (address != null && !address.trim().isEmpty())
                ? address.trim()
                : (name == null ? null : name.trim());
        if (label == null || label.isEmpty()) {
            throw new IllegalArgumentException("Household address (or name) is required");
        }

        Household h = new Household();
        h.setId(UUID.randomUUID());
        h.setName(label);
        h.setAddress(label);
        h.setScore(0);
        h.setHomeCode(generateUniqueHomeCode());

        householdMapper.createHousehold(h);
        return householdMapper.getHouseholdById(h.getId());
    }

    public Household joinHouseholdByHomeCode(UUID profileId, String homeCode) {
        if (homeCode == null) {
            throw new IllegalArgumentException("homeCode is required");
        }
        String code = homeCode.trim();
        if (!code.matches("^\\d{6}$")) {
            throw new IllegalArgumentException("homeCode must be 6 digits");
        }

        Household household = householdMapper.getHouseholdByHomeCode(code);
        if (household == null) {
            throw new IllegalArgumentException("Invalid home code");
        }

        addMember(household.getId(), profileId);
        return householdMapper.getHouseholdById(household.getId());
    }

    public Household createHouseholdAndInvite(UUID creatorProfileId, String name, String address, List<String> roommateEmails) {
        Household household = createHousehold(name, address);
        // Creator becomes member immediately.
        addMember(household.getId(), creatorProfileId);

        if (roommateEmails != null) {
            for (String email : roommateEmails) {
                inviteService.inviteByEmail(household.getId(), creatorProfileId, email);
            }
        }
        return household;
    }

    public void addMember(UUID householdId, UUID profileId) {
        householdMemberMapper.addMember(UUID.randomUUID(), householdId, profileId);
    }

    public List<Profile> getMembers(UUID householdId) {
        return householdMemberMapper.getMembers(householdId);
    }

    @Transactional
    public void leaveHousehold(UUID householdId, UUID profileId) {
        // Remove the member
        householdMemberMapper.removeMember(householdId, profileId);

        // Check if household is now empty
        int remainingMembers = householdMemberMapper.countMembers(householdId);
        if (remainingMembers == 0) {
            // Auto-delete the household if no members left
            householdMapper.deleteHousehold(householdId);
        }
    }

    private String generateUniqueHomeCode() {
        // Best-effort uniqueness: retry a few times to avoid collisions.
        for (int i = 0; i < 25; i++) {
            int n = ThreadLocalRandom.current().nextInt(0, 1_000_000);
            String code = String.format("%06d", n);
            if (householdMapper.getHouseholdByHomeCode(code) == null) {
                return code;
            }
        }
        throw new IllegalStateException("Could not generate unique home code");
    }
}

