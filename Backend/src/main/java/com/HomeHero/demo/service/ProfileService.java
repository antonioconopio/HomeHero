package com.HomeHero.demo.service;

import com.HomeHero.demo.model.Profile;
import com.HomeHero.demo.persistance.ProfileMapper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

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
}
