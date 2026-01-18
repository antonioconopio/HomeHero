package com.HomeHero.demo.dto;

public class UpdateExpenseRequest {

    private String item;
    private float cost;

    public UpdateExpenseRequest() {}

    public UpdateExpenseRequest(String item, float cost) {
        this.item = item;
        this.cost = cost;
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
}
