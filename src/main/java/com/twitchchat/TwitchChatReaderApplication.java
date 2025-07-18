package com.twitchchat;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

/**
 * Spring Boot main application class for Twitch Chat Reader
 */
@SpringBootApplication
@EnableScheduling
@EnableAsync
@EnableConfigurationProperties
@EnableJpaRepositories
public class TwitchChatReaderApplication {

    public static void main(String[] args) {
        System.out.println("=== Twitch Chat Reader ===");
        System.out.println("Starting Spring Boot application...\n");
        
        SpringApplication.run(TwitchChatReaderApplication.class, args);
    }
}