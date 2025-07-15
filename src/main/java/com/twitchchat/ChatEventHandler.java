package com.twitchchat;

import com.github.twitch4j.chat.events.channel.ChannelMessageEvent;
import com.github.twitch4j.chat.events.channel.UserJoinEvent;
import com.github.twitch4j.chat.events.channel.UserLeaveEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Handles various Twitch chat events and formats them for console display
 */
public class ChatEventHandler {
    private static final Logger logger = LoggerFactory.getLogger(ChatEventHandler.class);
    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("HH:mm:ss");

    /**
     * Handle incoming chat messages
     */
    public void onChannelMessage(ChannelMessageEvent event) {
        try {
            String timestamp = LocalDateTime.now().format(TIME_FORMATTER);
            String username = event.getUser().getName();
            String message = event.getMessage();
            String channel = event.getChannel().getName();

            // Format and display the message
            String formattedMessage = String.format("[%s] %s: %s", 
                timestamp, username, message);
            
            System.out.println(formattedMessage);
            
            // Log the message for debugging
            logger.debug("Message in {}: {} - {}", channel, username, message);
            
        } catch (Exception e) {
            logger.error("Error processing channel message: {}", e.getMessage(), e);
        }
    }

    /**
     * Handle user join events
     */
    public void onUserJoin(UserJoinEvent event) {
        try {
            String timestamp = LocalDateTime.now().format(TIME_FORMATTER);
            String username = event.getUser().getName();
            String channel = event.getChannel().getName();

            // Format and display the join message
            String joinMessage = String.format("[%s] --> %s joined the chat", 
                timestamp, username);
            
            System.out.println(joinMessage);
            
            logger.debug("User joined {}: {}", channel, username);
            
        } catch (Exception e) {
            logger.error("Error processing user join event: {}", e.getMessage(), e);
        }
    }

    /**
     * Handle user leave events
     */
    public void onUserLeave(UserLeaveEvent event) {
        try {
            String timestamp = LocalDateTime.now().format(TIME_FORMATTER);
            String username = event.getUser().getName();
            String channel = event.getChannel().getName();

            // Format and display the leave message
            String leaveMessage = String.format("[%s] <-- %s left the chat", 
                timestamp, username);
            
            System.out.println(leaveMessage);
            
            logger.debug("User left {}: {}", channel, username);
            
        } catch (Exception e) {
            logger.error("Error processing user leave event: {}", e.getMessage(), e);
        }
    }
}
