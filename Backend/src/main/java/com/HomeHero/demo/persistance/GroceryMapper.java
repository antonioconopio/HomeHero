package com.HomeHero.demo.persistance;

import com.HomeHero.demo.model.Grocery;
import com.HomeHero.demo.model.Profile;
import org.apache.ibatis.annotations.*;

import java.util.List;
import java.util.UUID;

@Mapper
public interface GroceryMapper {

    @Select("SELECT * FROM public.grocery WHERE household_id = #{household_id}")
    @Results({
        @Result(property = "id", column = "id"),
        @Result(property = "profile_id", column = "profile_id"),
        @Result(property = "grocery_name", column = "grocery_name"),
        @Result(property = "created_at", column = "created_at"),
        @Result(property = "household_id", column = "household_id")
    })
    List<Grocery> getGroceryByID(@Param("household_id") UUID household_id);

    @Insert("""
        INSERT INTO public.grocery (
            id,
            profile_id,
            grocery_name,
            created_at,
            household_id
        )
        VALUES (
            #{id},
            #{profile_id},
            #{grocery_name},
            #{created_at},
            #{household_id}
        )
    """)
    void insertGrocery(Grocery grocery);

    @Delete("DELETE FROM public.grocery WHERE id = #{id}")
    void deleteGrocery(@Param("id") UUID id);

    @Update("""
        UPDATE public.grocery
        SET
            grocery_name = #{grocery.grocery_name}
        WHERE id = #{grocery.id}
    """)
    void updateGrocery(@Param("grocery") Grocery grocery);
}
