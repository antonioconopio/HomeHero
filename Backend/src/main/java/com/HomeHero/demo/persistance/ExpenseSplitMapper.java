package com.HomeHero.demo.persistance;

import com.HomeHero.demo.model.ExpenseSplit;
import org.apache.ibatis.annotations.*;

import java.util.List;
import java.util.UUID;

@Mapper
public interface ExpenseSplitMapper {

    @Insert("""
        INSERT INTO public.expense_to_split (expense_id, profile_id, amount, paid)
        VALUES (#{expenseId}, #{profileId}, #{amount}, #{paid})
        RETURNING id
    """)
    void insert(ExpenseSplit split);

    @Select("""
        SELECT
            id,
            expense_id AS expenseId,
            profile_id AS profileId,
            amount,
            COALESCE(paid, false) AS paid
        FROM public.expense_to_split
        WHERE expense_id = #{expenseId}
    """)
    List<ExpenseSplit> getSplitsByExpense(@Param("expenseId") UUID expenseId);

    @Select("""
        SELECT
            es.id,
            es.expense_id AS expenseId,
            es.profile_id AS profileId,
            es.amount,
            COALESCE(es.paid, false) AS paid
        FROM public.expense_to_split es
        JOIN public.expense e ON es.expense_id = e.id
        WHERE es.profile_id = #{profileId}
        AND e.household_id = #{householdId}
    """)
    List<ExpenseSplit> getSplitsByProfileAndHousehold(@Param("profileId") UUID profileId, @Param("householdId") UUID householdId);

    @Select("""
        SELECT
            id,
            expense_id AS expenseId,
            profile_id AS profileId,
            amount,
            COALESCE(paid, false) AS paid
        FROM public.expense_to_split
        WHERE id = #{splitId}
    """)
    ExpenseSplit getSplitById(@Param("splitId") UUID splitId);

    @Update("""
        UPDATE public.expense_to_split
        SET paid = #{paid}
        WHERE id = #{splitId}
    """)
    void updatePaidStatus(@Param("splitId") UUID splitId, @Param("paid") boolean paid);

    @Delete("DELETE FROM public.expense_to_split WHERE expense_id = #{expenseId}")
    void deleteSplitsByExpense(@Param("expenseId") UUID expenseId);
}
