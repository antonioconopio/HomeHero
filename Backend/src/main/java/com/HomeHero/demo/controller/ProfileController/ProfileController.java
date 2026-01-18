package com.HomeHero.demo.controller.ProfileController;

import com.HomeHero.demo.model.Profile;
import com.HomeHero.demo.service.profile.ProfileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.security.core.Authentication;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
public class ProfileController {

    private final ProfileService profileService;

    @Autowired
    public ProfileController(ProfileService profileService) {
        this.profileService = profileService;
    }

    @RequestMapping(value = "/getProfile", produces = "application/json", method = RequestMethod.GET)
    public Profile getProfile() {
        //String userId = (String) authentication.getPrincipal();

        return profileService.getProfileById(UUID.fromString("d3576ad7-6f1f-490a-82a3-3a2de80d186f"));
    }
}
