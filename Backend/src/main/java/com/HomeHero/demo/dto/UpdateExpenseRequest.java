package com.HomeHero.demo.dto;

public class UpdateExpenseRequest {

    private String item;
    private float cost;

    public String getItem() {
        return item;
    }

    public float getCost() {
        return cost;
    }

    public void setItem(String item) {
        this.item = item;
    }

    public void setCost(float cost) {
        this.cost = cost;
    }
    
}
