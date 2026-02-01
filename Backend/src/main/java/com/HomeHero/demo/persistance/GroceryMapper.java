package com.HomeHero.demo.persistance;

import com.HomeHero.demo.model.Grocery;
import com.HomeHero.demo.model.Profile;
import org.apache.ibatis.annotations.*;

import java.util.List;
import java.util.UUID;

@Mapper
public interface GroceryMapper {

    @Select("SELECT * FROM public.grocery WHERE household_id = #{household_id}")
    List<Grocery> getGroceryByID(@Param("household_id") UUID household_id);

    @Insert("""
        INSERT INTO public.grocery (
        id,
        profile_id,
        grocery_name,
        grocery_cost,
        created_at,
        household_id
        ) VALUES (
        #{id},
        #{profileId},
        #{groceryName},
        #{groceryCost},
        #{createdAt},
        #{householdId}
        )
        """)
    void insertGrocery(Grocery grocery);

    @Delete("DELETE FROM public.grocery WHERE id = #{id}")
    void deleteGrocery(@Param("id") UUID id);

    @Update("""
        UPDATE public.grocery
        SET
            profile_id = #{grocery.profileId},
            grocery_name = #{grocery.groceryName},
            grocery_cost = #{grocery.groceryCost},
            created_at = #{grocery.createdAt},
            household_id = #{grocery.householdId}
        WHERE id = #{grocery.id}
    """)
    void updateGrocery(@Param("grocery") Grocery grocery);
}