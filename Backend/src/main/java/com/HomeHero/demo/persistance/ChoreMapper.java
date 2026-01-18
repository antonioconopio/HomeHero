package com.HomeHero.demo.persistance;

import com.HomeHero.demo.model.Chore;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.UUID;

@Mapper
public interface ChoreMapper {

    @Select("""
            SELECT *
            FROM (
              SELECT
                th.household_id AS household_id,
                t.id AS id,
                t.task_name AS title,
                NULL::text AS description,
                t.task_due_date AS due_at,
                NULL::date AS start_date,
                NULL::date AS end_date,
                'never'::text AS repeat_rule,
                NULL::boolean AS rotate_enabled,
                NULL::text AS rotate_with_json,
                t.profile_id_assignee AS assignee_id,
                t.task_score AS impact,
                t.created_at AS created_at
              FROM public.task_to_household th
              JOIN public.task t ON t.id = th.task_id
              WHERE th.household_id = #{householdId}
            ) x
            ORDER BY created_at DESC
            """)
    List<Chore> getChoresByHouseholdId(@Param("householdId") UUID householdId);

    @Select("""
            SELECT
              NULL::uuid AS household_id,
              t.id AS id,
              t.task_name AS title,
              NULL::text AS description,
              t.task_due_date AS due_at,
              NULL::date AS start_date,
              NULL::date AS end_date,
              'never'::text AS repeat_rule,
              NULL::boolean AS rotate_enabled,
              NULL::text AS rotate_with_json,
              t.profile_id_assignee AS assignee_id,
              t.task_score AS impact,
              t.created_at AS created_at
            FROM public.task t
            WHERE t.id = #{id}
            """)
    Chore getChoreById(@Param("id") UUID id);

    @Insert("""
            INSERT INTO public.task
              (id, task_name, task_due_date, task_score, profile_id_assignee)
            VALUES
              (#{id}, #{title}, #{dueAt}, #{impact}, #{assigneeId})
            """)
    int createChore(Chore chore);
}

