package com.HomeHero.demo;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.HomeHero.demo.persistance")
public class HomeHeroApplication {

	public static void main(String[] args) {
		// Helps avoid "psql works but JVM times out" issues on some networks (IPv6 routing/DNS).
		System.setProperty("java.net.preferIPv4Stack", "true");
		SpringApplication.run(HomeHeroApplication.class, args);
	}

}
