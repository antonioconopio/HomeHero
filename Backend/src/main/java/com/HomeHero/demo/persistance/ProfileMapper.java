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

    @Select("""
            SELECT
                id,
                user_score AS userScore,
                first_name,
                last_name,
                email,
                phone_number,
                COALESCE(amount_owed, 0) AS amountOwed,
                COALESCE(amount_owed_to_user, 0) AS amountOwedToUser
            FROM public.profiles WHERE id = #{id}
            """)
    Profile getProfileById(@Param("id") UUID id);

    @Select("""
            SELECT
                id,
                user_score AS userScore,
                first_name,
                last_name,
                email,
                phone_number,
                COALESCE(amount_owed, 0) AS amountOwed,
                COALESCE(amount_owed_to_user, 0) AS amountOwedToUser
            FROM public.profiles
            WHERE lower(email) = lower(#{email})
            LIMIT 1
            """)
    Profile getProfileByEmail(@Param("email") String email);

    @Select("""
            SELECT
                id,
                user_score AS userScore,
                first_name,
                last_name,
                email,
                phone_number,
                COALESCE(amount_owed, 0) AS amountOwed,
                COALESCE(amount_owed_to_user, 0) AS amountOwedToUser
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

    @Update("""
            UPDATE public.profiles
            SET amount_owed = COALESCE(amount_owed, 0) + #{delta}
            WHERE id = #{profileId}
            """)
    int incrementAmountOwed(@Param("profileId") UUID profileId, @Param("delta") float delta);

    @Update("""
            UPDATE public.profiles
            SET amount_owed_to_user = COALESCE(amount_owed_to_user, 0) + #{delta}
            WHERE id = #{profileId}
            """)
    int incrementAmountOwedToUser(@Param("profileId") UUID profileId, @Param("delta") float delta);

    @Update("""
            UPDATE public.profiles
            SET first_name = #{firstName}, last_name = #{lastName}
            WHERE id = #{profileId}
            """)
    int updateProfile(@Param("profileId") UUID profileId, @Param("firstName") String firstName, @Param("lastName") String lastName);
}
