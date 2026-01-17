package com.HomeHero.demo.controller.ProfileController;

import com.HomeHero.demo.model.Profile;
import com.HomeHero.demo.service.ProfileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
public class ProfileController {
    //private final AuthService authService;
    private final ProfileService profileService;

    @Autowired
    public ProfileController(ProfileService profileService) {
        this.profileService = profileService;
    }

    @RequestMapping(value = "/getProfile", produces = "application/json", method = RequestMethod.GET)
    public String getProfile() {

//        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
//            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing Bearer token");
//        }
//
//        String token = authHeader.replace("Bearer ", "");
        //String userId = authService.getUserIdFromToken(token);
//        return profileService.getProfileById(UUID.fromString("userId"));
        return "HELLO";
    }
}
