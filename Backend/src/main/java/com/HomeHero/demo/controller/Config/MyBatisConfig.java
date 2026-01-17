package com.HomeHero.demo.controller.Config;

import com.HomeHero.demo.persistance.util.UUIDTypeHandler;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.mybatis.spring.boot.autoconfigure.ConfigurationCustomizer;

import java.util.UUID;

@Configuration
public class MyBatisConfig {

    @Bean
    public ConfigurationCustomizer mybatisConfigurationCustomizer() {
        return configuration ->
                configuration.getTypeHandlerRegistry().register(UUID.class, new UUIDTypeHandler());
    }
}
