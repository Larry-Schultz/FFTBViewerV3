package com.twitchchat.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * Spring Boot configuration properties for Twitch settings
 */
@Component
@ConfigurationProperties(prefix = "twitch")
public class TwitchProperties {
    
    private String accessToken;
    private String username;
    private String channelName;

    // Getters and Setters
    public String getAccessToken() {
        return accessToken;
    }

    public void setAccessToken(String accessToken) {
        this.accessToken = accessToken;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getChannelName() {
        return channelName;
    }

    public void setChannelName(String channelName) {
        this.channelName = channelName;
    }

    /**
     * Check if access token is configured
     */
    public boolean hasAccessToken() {
        return accessToken != null && !accessToken.trim().isEmpty();
    }

    /**
     * Check if username is configured
     */
    public boolean hasUsername() {
        return username != null && !username.trim().isEmpty();
    }

    /**
     * Get cleaned channel name (lowercase, no #)
     */
    public String getCleanChannelName() {
        if (channelName == null || channelName.trim().isEmpty()) {
            return null;
        }
        
        String cleaned = channelName.trim();
        if (cleaned.startsWith("#")) {
            cleaned = cleaned.substring(1);
        }
        return cleaned.toLowerCase();
    }
}