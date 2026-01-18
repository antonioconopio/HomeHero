package com.HomeHero.demo.persistance;

import com.HomeHero.demo.model.Schedule;
import com.HomeHero.demo.persistance.util.JSONBTypeHandler;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Result;
import org.apache.ibatis.annotations.Results;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.UUID;

@Mapper
public interface ScheduleMapper {

    @Results({
        @Result(column = "id", property = "id"),
        @Result(column = "user_id", property = "user_id"),
        @Result(column = "weekly", property = "weekly", typeHandler = JSONBTypeHandler.class)
    })
    @Select("SELECT * FROM public.schedules WHERE id = #{id}")
    Schedule getScheduleById(@Param("id") UUID id);

    @Results({
        @Result(column = "id", property = "id"),
        @Result(column = "user_id", property = "user_id"),
        @Result(column = "weekly", property = "weekly", typeHandler = JSONBTypeHandler.class)
    })
    @Select("SELECT * FROM public.schedules WHERE user_id = #{userId}")
    Schedule getScheduleByUserId(@Param("userId") UUID userId);

    @Insert("INSERT INTO public.schedules (id, user_id, weekly) VALUES (#{id}, #{userId}, #{weekly}::jsonb)")
    void insertSchedule(@Param("id") UUID id, @Param("userId") UUID userId, @Param("weekly") String weekly);

    @Update("UPDATE public.schedules SET weekly = #{weekly}::jsonb WHERE user_id = #{userId}")
    void updateScheduleByUserId(@Param("userId") UUID userId, @Param("weekly") String weekly);
}
