package com.HomeHero.demo.persistance;

import com.HomeHero.demo.model.Household;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.UUID;

@Mapper
public interface HouseholdMapper {

    // Existing table is singular: public.household (per current schema)
    // We alias fields to match the app-facing Household model shape.
    @Select("""
            SELECT
              id,
              address,
              home_code,
              address AS name,
              0 AS score,
              created_at
            FROM public.household
            ORDER BY created_at DESC
            """)
    List<Household> getAllHouseholds();

    @Select("""
            SELECT
              id,
              address,
              home_code,
              address AS name,
              0 AS score,
              created_at
            FROM public.household
            WHERE id = #{id}
            """)
    Household getHouseholdById(@Param("id") UUID id);

    @Insert("""
            INSERT INTO public.household (id, address, home_code)
            VALUES (#{id}, #{address}, #{homeCode})
            """)
    int createHousehold(Household household);

    @Select("""
            SELECT
              id,
              address,
              home_code,
              address AS name,
              0 AS score,
              created_at
            FROM public.household
            WHERE home_code = #{homeCode}
            LIMIT 1
            """)
    Household getHouseholdByHomeCode(@Param("homeCode") String homeCode);

    @Select("""
            SELECT
              h.id,
              h.address,
              h.home_code,
              h.address AS name,
              0 AS score,
              h.created_at
            FROM public.profile_to_household pth
            JOIN public.household h ON h.id = pth.household_id
            WHERE pth.profile_id = #{profileId}
            ORDER BY h.created_at DESC
            """)
    List<Household> getHouseholdsForProfile(@Param("profileId") UUID profileId);

    @Delete("""
            DELETE FROM public.household
            WHERE id = #{householdId}
            """)
    int deleteHousehold(@Param("householdId") UUID householdId);
}

