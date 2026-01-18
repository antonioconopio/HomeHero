package com.HomeHero.demo.service;

import com.HomeHero.demo.model.Profile;
import com.HomeHero.demo.persistance.ProfileMapper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class ProfileService {

    private ProfileMapper profileMapper;

    @Autowired
    public ProfileService(ProfileMapper profileMapper) {
        this.profileMapper = profileMapper;
    }

    public Profile getProfileById(UUID id) {
        return profileMapper.getProfileById(id);
    }

    public Profile getProfileByEmail(String email) {
        return profileMapper.getProfileByEmail(email);
    }

    public List<Profile> searchProfilesByEmail(String email) {
        if (email == null) return List.of();
        String q = email.trim();
        if (q.isEmpty()) return List.of();
        return profileMapper.searchProfilesByEmail(q);
    }
}
