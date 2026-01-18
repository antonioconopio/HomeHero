package com.HomeHero.demo.persistance;

import com.HomeHero.demo.model.Expense;
import org.apache.ibatis.annotations.*;

import java.util.List;
import java.util.UUID;

@Mapper
public interface ExpenseMapper {

    @Insert("""
        INSERT INTO public.expense (id, household_id, profile_id, item, cost, score, created_at)
        VALUES (#{id}, #{householdId}, #{profileId}, #{item}, #{cost}, #{score}, now())
    """)
    void insertExpense(Expense expense);

    @Select("SELECT id, household_id AS householdId, profile_id AS profileId, item, cost, score, created_at AS createdAt FROM public.expense WHERE id = #{id}")
    Expense getExpenseById(@Param("id") UUID id);

    @Select("SELECT id, household_id AS householdId, profile_id AS profileId, item, cost, score, created_at AS createdAt FROM public.expense WHERE household_id = #{householdId}")
    List<Expense> getExpensesByHouseholdId(@Param("householdId") UUID householdId);

    @Update("UPDATE public.expense SET item = #{item}, cost = #{cost} WHERE id = #{id}")
    void updateExpense(@Param("id") UUID id, @Param("item") String item, @Param("cost") float cost);

    @Delete("DELETE FROM public.expense WHERE id = #{id}")
    void deleteExpense(@Param("id") UUID id);
}
