package com.HomeHero.demo.dto;

import java.util.List;
import java.util.UUID;

public class CreateExpenseSplitRequest {

    private UUID profileId; 
    private String item;
    private float cost;
    private int score;
    private List<UUID> profileIds; 

    // Getters and setters
    public UUID getProfileId() { 
        return profileId; 
    }
   
    public void setProfileId(UUID profileId) { 
        this.profileId = profileId;
    }

    public String getItem() { 
        return item; 
    }

    public void setItem(String item) { 
        this.item = item; 
    }

    public float getCost() { 
        return cost; 
    }

    public void setCost(float cost) { 
        this.cost = cost; 
    }

    public int getScore() { 
        return score; 
    }

    public void setScore(int score) { 
        this.score = score; 
    }

    public List<UUID> getProfileIds() { 
        return profileIds; 
    }

    public void setProfileIds(List<UUID> profileIds) { 
        this.profileIds = profileIds; 
    }
}
