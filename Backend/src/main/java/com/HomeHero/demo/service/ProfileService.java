package com.HomeHero.demo.service;

import com.HomeHero.demo.model.Profile;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class ProfileService {

    @Autowired
    public ProfileService() {}

    public Profile getProfileById(UUID id) {
        return new Profile();
    }
}
