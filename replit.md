# Twitch Chat Reader - Java Application

## Overview

A Java console application that reads Twitch chat messages in real-time using the twitch4j library. The application connects to Twitch IRC and displays chat messages, user joins, and leaves with timestamps. Built with Maven and designed for easy configuration through environment variables or properties files.

## User Preferences

Preferred communication style: Simple, everyday language.

## System Architecture

**Technology Stack:**
- Java 11 (OpenJDK)
- Spring Boot 2.7.18 framework
- Maven 3.9.4 for build management
- twitch4j library for Twitch API integration
- Spring Boot integrated logging

**Design Pattern:**
- Spring Boot application with dependency injection
- Component-based architecture using Spring annotations
- Event-driven chat handling using twitch4j's event system
- Configuration management through Spring Boot properties
- CommandLineRunner interface for application startup
- Graceful shutdown handling with @PreDestroy annotation

## Key Components

**Main Classes:**
- `TwitchChatReaderApplication.java` - Spring Boot main application class
- `TwitchChatReader.java` - Spring component implementing CommandLineRunner for chat client management
- `ChatEventHandler.java` - Spring component handling incoming chat events and formatting display
- `TwitchProperties.java` - Spring Boot configuration properties class for Twitch settings
- `application.properties` - Spring Boot configuration file

**Features:**
- Real-time chat message display with timestamps
- User join/leave notifications
- Auto-reconnection on connection loss
- Graceful shutdown with 'q' command
- Flexible configuration via environment variables or config file

## Data Flow

1. Spring Boot application starts and loads configuration from `application.properties` and environment variables
2. Creates OAuth2 credential (anonymous if no token provided)
3. Initializes Twitch client and registers event handlers
4. Connects to specified Twitch channel
5. Listens for chat events and displays formatted messages
6. Monitors connection health and auto-reconnects if needed
7. User can quit gracefully with 'q' command

## External Dependencies

**Core Dependencies:**
- `spring-boot-starter` (2.7.18) - Spring Boot core functionality
- `spring-boot-configuration-processor` - Configuration properties support
- `twitch4j-chat` (1.19.0) - Twitch chat integration

**Build Tools:**
- Maven with Spring Boot plugin
- Java 11 runtime environment

## Configuration

**Required Settings:**
- `TWITCH_CHANNEL` environment variable or `twitch.channel-name` in application.properties

**Optional Settings:**
- `TWITCH_ACCESS_TOKEN` environment variable or `twitch.access-token` in application.properties (for authentication)
- `TWITCH_USERNAME` environment variable or `twitch.username` in application.properties (for bot identification)

## Deployment Strategy

**Local Development:**
- Run using Spring Boot with `mvn spring-boot:run` command
- Configuration through `application.properties` file
- Logs output to console using Spring Boot logging

**Environment Setup:**
- Java 11 installation required
- Maven 3.9.4 for dependency management
- No external database or web server needed

## Recent Changes

**July 15, 2025:**
- Fixed Java version compatibility issue (changed from Java 21 to Java 11)
- Resolved Maven build failures by updating Java environment setup
- Fixed workflow configuration to properly set JAVA_HOME and PATH
- Fixed OAuth credential handling for anonymous and authenticated connections
- Added secure credential management using Replit Secrets for TWITCH_ACCESS_TOKEN
- Added configurable username and channel properties for easy customization
- Converted entire project to Spring Boot framework with dependency injection
- Updated configuration system to use Spring Boot properties
- Removed problematic logback configuration in favor of Spring Boot logging
- Application now builds and runs successfully with full authentication
- Enhanced functionality with authenticated Twitch access (whispers, private channels, better rate limits)

**January 15, 2025:**
- Set up complete Java application for Twitch chat reading
- Configured Maven build system with all required dependencies
- Created proper environment setup script for Java and Maven
- Application successfully starts and handles configuration validation

---

**Current Status**: Application is running successfully with authenticated Twitch access, reading chat messages from "shroud" channel with full functionality enabled.