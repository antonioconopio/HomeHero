package com.HomeHero.demo.controller.GroceryController;

import com.HomeHero.demo.model.Grocery;
import com.HomeHero.demo.service.grocery.GroceryService;
import com.HomeHero.demo.util.CurrentUser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
public class GroceryController {

    private final GroceryService groceryService;
    private final CurrentUser currentUser;

    @Autowired
    public GroceryController(GroceryService groceryService, CurrentUser currentUser) {
        this.groceryService = groceryService;
        this.currentUser = currentUser;
    }

    @RequestMapping(value = "/getGrocery", produces = "application/json", method = RequestMethod.GET)
    public List<Grocery> getGrocery(@RequestParam String household_id) {
        return groceryService.getGroceries(household_id);
    }

    @RequestMapping(value = "/insertGrocery", produces = "application/json", consumes = "application/json", method = RequestMethod.POST)
    public Grocery insertGrocery(@RequestBody Grocery grocery) {
        UUID profileId = currentUser.getProfileId();
        grocery.setProfile_id(profileId);
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
