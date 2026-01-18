package com.HomeHero.demo.service.grocery;

import com.HomeHero.demo.model.Grocery;
import com.HomeHero.demo.model.GroceryToHousehold;
import com.HomeHero.demo.persistance.GroceryMapper;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class GroceryService {

    private GroceryMapper groceryMapper;

    public GroceryService(GroceryMapper groceryMapper) {
        this.groceryMapper = groceryMapper;
    }

    public List<Grocery> getGroceries(String household_id) {
        return groceryMapper.getGroceryByID(UUID.fromString(household_id));
    }

    public Grocery insertGrocery(Grocery grocery) {
        grocery.setId(UUID.randomUUID());
        groceryMapper.insertGrocery(grocery);
        return grocery;
    }

    public Grocery deleteGrocery(Grocery grocery) {
        groceryMapper.deleteGrocery(grocery.getId());
        return grocery;
    }

    public Grocery updateGrocery(Grocery grocery) {
        groceryMapper.updateGrocery(grocery);
        return grocery;
    }
}
