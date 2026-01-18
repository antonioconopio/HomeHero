package com.HomeHero.demo.controller.GroceryController;

import com.HomeHero.demo.model.Grocery;
import com.HomeHero.demo.service.grocery.GroceryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
public class GroceryController {

    private final GroceryService groceryService;

    @Autowired
    public GroceryController(GroceryService groceryService) {
        this.groceryService = groceryService;
    }

    @RequestMapping(value = "/getGrocery", produces = "application/json", method = RequestMethod.GET)
    public Grocery getGrocery() {
        //String userId = (String) authentication.getPrincipal();

        return new Grocery();
    }
}
