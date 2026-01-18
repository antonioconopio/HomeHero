package com.HomeHero.demo.persistance;

import com.HomeHero.demo.model.Profile;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;
import java.util.UUID;

@Mapper
public interface ProfileMapper {

    @Select("SELECT * from public.profiles")
    List<Profile> getAllProfiles();

    @Select("SELECT * FROM public.profiles WHERE id = #{id}")
    Profile getProfileById(@Param("id") UUID id);

    @Select("""
            SELECT *
            FROM public.profiles
            WHERE lower(email) = lower(#{email})
            LIMIT 1
            """)
    Profile getProfileByEmail(@Param("email") String email);

    @Select("""
            SELECT *
            FROM public.profiles
            WHERE email ILIKE CONCAT('%', #{email}, '%')
            ORDER BY email ASC
            LIMIT 10
            """)
    List<Profile> searchProfilesByEmail(@Param("email") String email);

    @Update("""
            UPDATE public.profiles
            SET user_score = COALESCE(user_score, 0) + #{delta}
            WHERE id = #{profileId}
            """)
    int incrementUserScore(@Param("profileId") UUID profileId, @Param("delta") int delta);
}
