package com.twitchchat.config;

import com.github.philippheuer.credentialmanager.domain.OAuth2Credential;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;

/**
 * Configuration class for Twitch API credentials and settings
 */
public class TwitchConfig {
    private static final Logger logger = LoggerFactory.getLogger(TwitchConfig.class);
    private static final String CONFIG_FILE = "config.properties";
    
    private String accessToken;
    private String channelName;
    private Properties properties;

    public TwitchConfig() {
        loadConfiguration();
    }

    /**
     * Load configuration from environment variables and properties file
     */
    private void loadConfiguration() {
        // Load from properties file first
        loadPropertiesFile();
        
        // Override with environment variables if available
        loadEnvironmentVariables();
        
        // Validate required configuration
        validateConfiguration();
    }

    /**
     * Load configuration from properties file
     */
    private void loadPropertiesFile() {
        properties = new Properties();
        
        try (FileInputStream fis = new FileInputStream(CONFIG_FILE)) {
            properties.load(fis);
            logger.info("Configuration loaded from {}", CONFIG_FILE);
            
        } catch (IOException e) {
            logger.warn("Could not load configuration file {}: {}", CONFIG_FILE, e.getMessage());
            // Create empty properties object to avoid null pointer exceptions
            properties = new Properties();
        }
    }

    /**
     * Load and override configuration from environment variables
     */
    private void loadEnvironmentVariables() {
        // Get access token from environment or properties
        accessToken = System.getenv("TWITCH_ACCESS_TOKEN");
        if (accessToken == null || accessToken.trim().isEmpty()) {
            accessToken = properties.getProperty("twitch.access.token", "");
        }

        // Get channel name from environment or properties
        channelName = System.getenv("TWITCH_CHANNEL");
        if (channelName == null || channelName.trim().isEmpty()) {
            channelName = properties.getProperty("twitch.channel.name", "");
        }

        logger.info("Configuration loaded - Channel: {}, Token configured: {}", 
            channelName, !accessToken.isEmpty());
    }

    /**
     * Validate that required configuration is present
     */
    private void validateConfiguration() {
        if (channelName == null || channelName.trim().isEmpty()) {
            throw new IllegalArgumentException(
                "Channel name is required. Set TWITCH_CHANNEL environment variable or " +
                "twitch.channel.name in config.properties"
            );
        }

        // Access token is optional for reading public chat
        if (accessToken == null || accessToken.trim().isEmpty()) {
            logger.warn("No access token provided. This may limit functionality for some channels.");
        }

        // Remove leading # if present in channel name
        if (channelName.startsWith("#")) {
            channelName = channelName.substring(1);
        }

        // Convert to lowercase as required by Twitch
        channelName = channelName.toLowerCase();
    }

    /**
     * Get OAuth2 credential for Twitch authentication
     */
    public OAuth2Credential getCredential() {
        if (accessToken != null && !accessToken.trim().isEmpty()) {
            return new OAuth2Credential("twitch", accessToken);
        } else {
            // Return anonymous credential for public chat
            return new OAuth2Credential("twitch", null);
        }
    }

    /**
     * Get the configured channel name
     */
    public String getChannelName() {
        return channelName;
    }

    /**
     * Get the access token
     */
    public String getAccessToken() {
        return accessToken;
    }

    /**
     * Check if access token is configured
     */
    public boolean hasAccessToken() {
        return accessToken != null && !accessToken.trim().isEmpty();
    }
}
