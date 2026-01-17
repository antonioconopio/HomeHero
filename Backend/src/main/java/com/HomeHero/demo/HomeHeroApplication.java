package com.HomeHero.demo;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.HomeHero.demo.persistance")
public class HomeHeroApplication {

	public static void main(String[] args) {
		SpringApplication.run(HomeHeroApplication.class, args);
	}

}
