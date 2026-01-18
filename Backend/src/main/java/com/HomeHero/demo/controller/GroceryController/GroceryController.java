package com.HomeHero.demo.controller.GroceryController;

import com.HomeHero.demo.model.Grocery;
import com.HomeHero.demo.service.grocery.GroceryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
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
    public List<Grocery> getGrocery(String household_id) {
        //String userId = (String) authentication.getPrincipal();

        return groceryService.getGroceries("5ca95d0d-e4f9-4957-9092-bb8f76643932");
    }

    @RequestMapping(value = "/insertGrocery", produces = "application/json", consumes = "application/json", method = RequestMethod.POST)
    public Grocery insertGrocery(@RequestBody Grocery grocery) {
        //String userId = (String) authentication.getPrincipal();

        return groceryService.insertGrocery(grocery);
    }

    @RequestMapping(value = "/deleteGrocery", produces = "application/json", consumes = "application/json", method = RequestMethod.DELETE)
    public Grocery deleteGrocery(@RequestBody Grocery grocery) {
        return groceryService.deleteGrocery(grocery);
    }

    @RequestMapping(value = "/updateGrocery", produces = "application/json", consumes = "application/json", method = RequestMethod.PUT)
    public Grocery updateGrocery(@RequestBody Grocery grocery) {
        return groceryService.updateGrocery(grocery);
    }
}
