package com.HomeHero.demo.persistance;

import com.HomeHero.demo.model.Expense;

import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;
import java.util.UUID;

@Mapper
public interface ExpenseMapper {

    @Select("""
        SELECT
            id,
            household_id AS householdId,
            profile_id AS profileId,
            item,
            cost,
            score,
            created_at AS createdAt
        FROM public.expense
        WHERE id = #{id}
    """)
    Expense getExpenseById(@Param("id") UUID id);

    @Select("""
        SELECT
            id,
            household_id AS householdId,
            profile_id AS profileId,
            item,
            cost,
            score,
            created_at AS createdAt
        FROM public.expense 
        WHERE household_id = #{householdId}
        ORDER BY created_at DESC
    """)
    List<Expense> getExpensesByHouseholdId(@Param("householdId") UUID householdId);

    @Select("""
        SELECT COALESCE(SUM(cost), 0)
        FROM public.expense
        WHERE household_id = #{householdId}
        AND created_at >= date_trunc('month', CURRENT_DATE)
    """)
    float getMonthlyTotalByHousehold(@Param("householdId") UUID householdId);

    @Update("""
        UPDATE public.expense
        SET item = #{item},
            cost = #{cost}
        WHERE id = #{expenseId}
    """)
    void updateExpense(@Param("expenseId") UUID expenseId, @Param("item") String item, @Param("cost") float cost);

    @Insert("""
        INSERT INTO public.expense (id, household_id, profile_id, item, cost, score)
        VALUES (#{id}, #{householdId}, #{profileId}, #{item}, #{cost}, #{score})
    """)
    void insertExpense(Expense expense);

    @Delete("DELETE FROM public.expense WHERE id = #{id}")
    void deleteExpense(@Param("id") UUID id);
}
