package com.HomeHero.demo.model;

import com.fasterxml.jackson.databind.JsonNode;
import lombok.Getter;

import java.util.UUID;

public class Schedule {
    @Getter
    private UUID id;
    
    @Getter
    private UUID user_id;
    
    @Getter
    private JsonNode weekly;

    public Schedule() {}

    public void setId(UUID id) {
        this.id = id;
    }

    public void setUser_id(UUID user_id) {
        this.user_id = user_id;
    }

    public void setWeekly(JsonNode weekly) {
        this.weekly = weekly;
    }
}
