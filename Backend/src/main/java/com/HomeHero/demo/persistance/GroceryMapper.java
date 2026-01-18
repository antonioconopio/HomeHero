package com.HomeHero.demo.persistance;

import com.HomeHero.demo.model.Grocery;
import com.HomeHero.demo.model.Profile;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.UUID;

@Mapper
public interface GroceryMapper {

    @Select("SELECT * FROM public.grocery WHERE household_id = #{household_id}")
    Grocery getGroceryByHousehold(@Param("household_id") UUID household_id);
}