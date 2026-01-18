package com.HomeHero.demo.persistance;

import com.HomeHero.demo.model.HouseholdInvite;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.UUID;

@Mapper
public interface HouseholdInviteMapper {

    @Insert("""
            INSERT INTO public.household_invite
              (id, household_id, inviter_profile_id, invitee_profile_id, invitee_email, status)
            VALUES
              (#{id}, #{householdId}, #{inviterProfileId}, #{inviteeProfileId}, #{inviteeEmail}, #{status})
            """)
    int createInvite(HouseholdInvite invite);

    @Select("""
            SELECT
              hi.*,
              h.address AS household_address
            FROM public.household_invite hi
            JOIN public.household h ON h.id = hi.household_id
            WHERE (
                    (hi.invitee_profile_id = #{profileId})
                 OR (hi.invitee_email IS NOT NULL AND lower(hi.invitee_email) = lower(#{email}))
                  )
              AND hi.inviter_profile_id <> #{profileId}
            ORDER BY hi.created_at DESC
            """)
    List<HouseholdInvite> getInvitesForProfile(@Param("profileId") UUID profileId, @Param("email") String email);
}

