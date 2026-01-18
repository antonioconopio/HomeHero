package com.HomeHero.demo.controller.ScheduleController;

import com.HomeHero.demo.model.Schedule;
import com.HomeHero.demo.service.ScheduleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
public class ScheduleController {

    private final ScheduleService scheduleService;

    @Autowired
    public ScheduleController(ScheduleService scheduleService) {
        this.scheduleService = scheduleService;
    }

    @RequestMapping(value = "/schedule/{userId}", produces = "application/json", method = RequestMethod.GET)
    public Schedule getScheduleByUserId(@PathVariable UUID userId) {
        Schedule schedule = scheduleService.getScheduleByUserId(userId);
        if (schedule == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Schedule not found for user");
        }
        return schedule;
    }

    @RequestMapping(value = "/schedule/{userId}", produces = "application/json", method = RequestMethod.POST)
    public void createSchedule(@PathVariable UUID userId, @RequestBody Object weeklySchedule) {
        try {
            scheduleService.createSchedule(userId, weeklySchedule);
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Failed to create schedule", e);
        }
    }

    @RequestMapping(value = "/schedule/{userId}", produces = "application/json", method = RequestMethod.PUT)
    public void updateSchedule(@PathVariable UUID userId, @RequestBody Object weeklySchedule) {
        try {
            scheduleService.updateSchedule(userId, weeklySchedule);
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Failed to update schedule", e);
        }
    }
}
