package com.HomeHero.demo.persistance;

import com.HomeHero.demo.model.Profile;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.UUID;

@Mapper
public interface HouseholdMemberMapper {

    @Insert("""
            INSERT INTO public.profile_to_household (id, household_id, profile_id)
            VALUES (#{id}, #{householdId}, #{profileId})
            """)
    int addMember(@Param("id") UUID id, @Param("householdId") UUID householdId, @Param("profileId") UUID profileId);

    @Select("""
            SELECT p.*
            FROM public.profile_to_household pth
            JOIN public.profiles p ON p.id = pth.profile_id
            WHERE pth.household_id = #{householdId}
            ORDER BY p.first_name ASC, p.last_name ASC
            """)
    List<Profile> getMembers(@Param("householdId") UUID householdId);
}

