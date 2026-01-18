package com.HomeHero.demo.persistance;

import com.HomeHero.demo.model.ExpenseSplit;
import org.apache.ibatis.annotations.*;

import java.util.List;
import java.util.UUID;

@Mapper
public interface ExpenseSplitMapper {

    @Insert("""
        INSERT INTO public.expense_to_split (expense_id, profile_id, amount)
        VALUES (#{expenseId}, #{profileId}, #{amount})
        RETURNING id
    """)
    void insert(ExpenseSplit split);

    @Select("""
        SELECT
            id,
            expense_id AS expenseId,
            profile_id AS profileId,
            amount
        FROM public.expense_split
        WHERE expense_id = #{expenseId}
    """)
    List<ExpenseSplit> getSplitsByExpense(@Param("expenseId") UUID expenseId);
}
