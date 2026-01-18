package com.HomeHero.demo.persistance;

import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.UUID;

@Mapper
public interface TaskToHouseholdMapper {

    @Insert("""
            INSERT INTO public.task_to_household (id, household_id, task_id, profile_id)
            VALUES (#{id}, #{householdId}, #{taskId}, #{profileId})
            """)
    int linkTaskToHousehold(
            @Param("id") UUID id,
            @Param("householdId") UUID householdId,
            @Param("taskId") UUID taskId,
            @Param("profileId") UUID profileId
    );
}

