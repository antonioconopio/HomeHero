package com.HomeHero.demo.service;

import com.HomeHero.demo.model.Schedule;
import com.HomeHero.demo.persistance.ScheduleMapper;
import com.fasterxml.jackson.databind.ObjectMapper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class ScheduleService {

    private ScheduleMapper scheduleMapper;
    private ObjectMapper objectMapper;

    @Autowired
    public ScheduleService(ScheduleMapper scheduleMapper, ObjectMapper objectMapper) {
        this.scheduleMapper = scheduleMapper;
        this.objectMapper = objectMapper;
    }

    public Schedule getScheduleById(UUID id) {
        return scheduleMapper.getScheduleById(id);
    }

    public Schedule getScheduleByUserId(UUID userId) {
        return scheduleMapper.getScheduleByUserId(userId);
    }

    public void createSchedule(UUID userId, Object weeklySchedule) throws Exception {
        UUID scheduleId = UUID.randomUUID();
        String weeklyJson = objectMapper.writeValueAsString(weeklySchedule);
        scheduleMapper.insertSchedule(scheduleId, userId, weeklyJson);
    }

    public void updateSchedule(UUID userId, Object weeklySchedule) throws Exception {
        String weeklyJson = objectMapper.writeValueAsString(weeklySchedule);
        scheduleMapper.updateScheduleByUserId(userId, weeklyJson);
    }
}
