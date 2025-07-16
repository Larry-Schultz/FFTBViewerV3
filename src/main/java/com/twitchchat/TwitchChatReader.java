package com.twitchchat;

import com.github.philippheuer.credentialmanager.domain.OAuth2Credential;
import com.github.twitch4j.TwitchClientBuilder;
import com.github.twitch4j.chat.TwitchChat;
import com.twitchchat.config.TwitchProperties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import javax.annotation.PreDestroy;
import java.util.Scanner;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

/**
 * Main Spring Boot component for reading Twitch chat messages in real-time
 */
@Component
public class TwitchChatReader implements CommandLineRunner {
    private static final Logger logger = LoggerFactory.getLogger(TwitchChatReader.class);
    
    @Autowired
    private TwitchProperties twitchProperties;
    
    @Autowired
    private ChatEventHandler eventHandler;
    
    private TwitchChat twitchChat;
    private boolean isConnected = false;
    private ScheduledExecutorService reconnectService;

    public TwitchChatReader() {
        this.reconnectService = Executors.newScheduledThreadPool(1);
    }

    @Override
    public void run(String... args) throws Exception {
        start();
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
                    .withChatAccount(getCredential())
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

        logger.info("Event handlers registered");
    }

    /**
     * Join the configured Twitch channel
     */
    private void joinChannel() {
        String channelName = twitchProperties.getCleanChannelName();
        
        if (channelName == null || channelName.trim().isEmpty()) {
            throw new IllegalArgumentException("Channel name is required. Please set twitch.channel-name property");
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
     * Wait for user input to keep application running (deployment-friendly)
     */
    private void waitForUserInput() {
        // Check if we're in a deployment environment (no interactive console)
        if (!isInteractiveEnvironment()) {
            logger.info("Running in deployment mode - keeping application alive without console input");
            // Keep the application running indefinitely in deployment
            keepAliveForDeployment();
            return;
        }
        
        // Interactive mode for local development
        logger.info("Running in interactive mode - waiting for 'q' to quit");
        Scanner scanner = new Scanner(System.in);
        String input;
        
        try {
            while (true) {
                if (System.in.available() > 0) {
                    input = scanner.nextLine();
                    
                    if ("q".equalsIgnoreCase(input.trim())) {
                        System.out.println("Shutting down Twitch Chat Reader...");
                        shutdown();
                        break;
                    }
                } else {
                    // Sleep briefly to avoid busy waiting
                    Thread.sleep(100);
                }
            }
        } catch (Exception e) {
            logger.info("Console input not available, switching to deployment mode");
            keepAliveForDeployment();
        } finally {
            scanner.close();
        }
    }
    
    /**
     * Check if we're running in an interactive environment
     */
    private boolean isInteractiveEnvironment() {
        try {
            // Check if System.in is available and connected to a terminal
            return System.console() != null && System.in.available() >= 0;
        } catch (Exception e) {
            return false;
        }
    }
    
    /**
     * Keep the application alive in deployment mode
     */
    private void keepAliveForDeployment() {
        try {
            // Register shutdown hook for graceful shutdown
            Runtime.getRuntime().addShutdownHook(new Thread(() -> {
                logger.info("Shutdown hook triggered - gracefully stopping Twitch Chat Reader");
                shutdown();
            }));
            
            // Keep the main thread alive
            while (!Thread.currentThread().isInterrupted()) {
                Thread.sleep(5000); // Sleep for 5 seconds between checks
            }
        } catch (InterruptedException e) {
            logger.info("Application interrupted - shutting down");
            Thread.currentThread().interrupt();
            shutdown();
        }
    }

    /**
     * Get OAuth2 credential for Twitch authentication
     */
    private OAuth2Credential getCredential() {
        if (twitchProperties.hasAccessToken()) {
            return new OAuth2Credential("twitch", twitchProperties.getAccessToken());
        } else {
            // Return null for anonymous connections to public chat
            return null;
        }
    }

    /**
     * Gracefully shutdown the application
     */
    @PreDestroy
    public void shutdown() {
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


}
