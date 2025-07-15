package com.twitchchat;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

/**
 * Spring Boot main application class for Twitch Chat Reader
 */
@SpringBootApplication
@EnableConfigurationProperties
public class TwitchChatReaderApplication {

    public static void main(String[] args) {
        System.out.println("=== Twitch Chat Reader ===");
        System.out.println("Starting Spring Boot application...\n");
        
        SpringApplication.run(TwitchChatReaderApplication.class, args);
    }
}