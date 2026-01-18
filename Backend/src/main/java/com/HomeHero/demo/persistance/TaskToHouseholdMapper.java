package com.HomeHero.demo.persistance;

import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

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

    @Delete("""
            DELETE FROM public.task_to_household
            WHERE household_id = #{householdId}
              AND task_id = #{taskId}
            """)
    int unlinkTaskFromHousehold(@Param("householdId") UUID householdId, @Param("taskId") UUID taskId);

    @Select("""
            SELECT profile_id
            FROM public.task_to_household
            WHERE household_id = #{householdId}
              AND task_id = #{taskId}
            LIMIT 1
            """)
    UUID getLinkedProfileId(@Param("householdId") UUID householdId, @Param("taskId") UUID taskId);
}

