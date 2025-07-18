package com.twitchchat.model;

import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;

/**
 * Model class representing a Twitch chat message
 */
public class ChatMessage {
    private String username;
    private String message;
    private String timestamp;
    private String channel;

    public ChatMessage() {}

    public ChatMessage(String username, String message, String channel) {
        this.username = username;
        this.message = message;
        this.channel = channel;
        // Use ISO instant format for proper JavaScript Date parsing
        this.timestamp = LocalDateTime.now().atZone(ZoneOffset.UTC).toInstant().toString();
    }

    // Getters and Setters
    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(String timestamp) {
        this.timestamp = timestamp;
    }

    public String getChannel() {
        return channel;
    }

    public void setChannel(String channel) {
        this.channel = channel;
    }
}