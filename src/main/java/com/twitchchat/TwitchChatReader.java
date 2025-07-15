package com.twitchchat;

import com.github.twitch4j.TwitchClientBuilder;
import com.github.twitch4j.chat.TwitchChat;
import com.twitchchat.config.TwitchConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Scanner;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

/**
 * Main application class for reading Twitch chat messages in real-time
 */
public class TwitchChatReader {
    private static final Logger logger = LoggerFactory.getLogger(TwitchChatReader.class);
    private TwitchChat twitchChat;
    private ChatEventHandler eventHandler;
    private TwitchConfig config;
    private boolean isConnected = false;
    private ScheduledExecutorService reconnectService;

    public TwitchChatReader() {
        this.config = new TwitchConfig();
        this.eventHandler = new ChatEventHandler();
        this.reconnectService = Executors.newScheduledThreadPool(1);
    }

    /**
     * Initialize and start the Twitch chat client
     */
    public void start() {
        logger.info("Starting Twitch Chat Reader...");
        
        try {
            // Initialize Twitch client
            initializeTwitchClient();
            
            // Join the configured channel
            joinChannel();
            
            // Start monitoring connection
            startConnectionMonitoring();
            
            // Keep the application running
            waitForUserInput();
            
        } catch (Exception e) {
            logger.error("Failed to start Twitch Chat Reader: {}", e.getMessage(), e);
            System.err.println("Error: " + e.getMessage());
            System.exit(1);
        }
    }

    /**
     * Initialize the Twitch client with proper configuration
     */
    private void initializeTwitchClient() {
        try {
            // Build Twitch client with chat module
            twitchChat = TwitchClientBuilder.builder()
                    .withEnableChat(true)
                    .withChatAccount(config.getCredential())
                    .build()
                    .getChat();

            // Register event handlers
            registerEventHandlers();
            
            logger.info("Twitch client initialized successfully");
            
        } catch (Exception e) {
            throw new RuntimeException("Failed to initialize Twitch client", e);
        }
    }

    /**
     * Register all event handlers for chat events
     */
    private void registerEventHandlers() {
        // Handle incoming chat messages
        twitchChat.getEventManager().onEvent(
            com.github.twitch4j.chat.events.channel.ChannelMessageEvent.class,
            eventHandler::onChannelMessage
        );

        // Handle user joins
        twitchChat.getEventManager().onEvent(
            com.github.twitch4j.chat.events.channel.UserJoinEvent.class,
            eventHandler::onUserJoin
        );

        // Handle user leaves
        twitchChat.getEventManager().onEvent(
            com.github.twitch4j.chat.events.channel.UserLeaveEvent.class,
            eventHandler::onUserLeave
        );

        // Handle connection events
        twitchChat.getEventManager().onEvent(
            com.github.twitch4j.common.events.domain.EventSocket.class,
            event -> {
                if (event.getType().equals("CONNECTED")) {
                    isConnected = true;
                    logger.info("Connected to Twitch IRC");
                    System.out.println("✓ Connected to Twitch chat");
                } else if (event.getType().equals("DISCONNECTED")) {
                    isConnected = false;
                    logger.warn("Disconnected from Twitch IRC");
                    System.out.println("✗ Disconnected from Twitch chat");
                }
            }
        );

        logger.info("Event handlers registered");
    }

    /**
     * Join the configured Twitch channel
     */
    private void joinChannel() {
        String channelName = config.getChannelName();
        
        if (channelName == null || channelName.trim().isEmpty()) {
            throw new IllegalArgumentException("Channel name is required. Please set TWITCH_CHANNEL environment variable or update config.properties");
        }

        try {
            twitchChat.joinChannel(channelName);
            isConnected = true;
            
            logger.info("Joined channel: {}", channelName);
            System.out.println("Joined channel: " + channelName);
            System.out.println("Listening for chat messages... (Press 'q' and Enter to quit)\n");
            
        } catch (Exception e) {
            throw new RuntimeException("Failed to join channel: " + channelName, e);
        }
    }

    /**
     * Start monitoring connection and implement auto-reconnect
     */
    private void startConnectionMonitoring() {
        reconnectService.scheduleAtFixedRate(() -> {
            if (!isConnected) {
                logger.info("Attempting to reconnect...");
                System.out.println("Attempting to reconnect...");
                
                try {
                    // Reinitialize and reconnect
                    initializeTwitchClient();
                    joinChannel();
                    
                } catch (Exception e) {
                    logger.error("Reconnection failed: {}", e.getMessage());
                    System.err.println("Reconnection failed: " + e.getMessage());
                }
            }
        }, 30, 30, TimeUnit.SECONDS);
    }

    /**
     * Wait for user input to keep application running
     */
    private void waitForUserInput() {
        Scanner scanner = new Scanner(System.in);
        String input;
        
        while (true) {
            input = scanner.nextLine();
            
            if ("q".equalsIgnoreCase(input.trim())) {
                System.out.println("Shutting down Twitch Chat Reader...");
                shutdown();
                break;
            }
        }
        
        scanner.close();
    }

    /**
     * Gracefully shutdown the application
     */
    private void shutdown() {
        try {
            if (twitchChat != null) {
                twitchChat.close();
            }
            
            if (reconnectService != null) {
                reconnectService.shutdown();
            }
            
            logger.info("Twitch Chat Reader shutdown complete");
            System.out.println("Goodbye!");
            
        } catch (Exception e) {
            logger.error("Error during shutdown: {}", e.getMessage(), e);
        }
    }

    /**
     * Main entry point
     */
    public static void main(String[] args) {
        System.out.println("=== Twitch Chat Reader ===");
        System.out.println("Starting application...\n");
        
        TwitchChatReader reader = new TwitchChatReader();
        
        // Add shutdown hook for graceful exit
        Runtime.getRuntime().addShutdownHook(new Thread(reader::shutdown));
        
        reader.start();
    }
}
