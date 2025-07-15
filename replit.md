# Twitch Chat Reader - Java Application

## Overview

A Java console application that reads Twitch chat messages in real-time using the twitch4j library. The application connects to Twitch IRC and displays chat messages, user joins, and leaves with timestamps. Built with Maven and designed for easy configuration through environment variables or properties files.

## User Preferences

Preferred communication style: Simple, everyday language.

## System Architecture

**Technology Stack:**
- Java 21 (OpenJDK)
- Maven 3.9.4 for build management
- twitch4j library for Twitch API integration
- SLF4J with Logback for logging

**Design Pattern:**
- Event-driven architecture using twitch4j's event system
- Configuration management through properties and environment variables
- Graceful shutdown handling with cleanup procedures

## Key Components

**Main Classes:**
- `TwitchChatReader.java` - Main application entry point and chat client management
- `ChatEventHandler.java` - Handles incoming chat events and formats display
- `TwitchConfig.java` - Configuration loading from environment and properties files
- `logback.xml` - Logging configuration with console and file output

**Features:**
- Real-time chat message display with timestamps
- User join/leave notifications
- Auto-reconnection on connection loss
- Graceful shutdown with 'q' command
- Flexible configuration via environment variables or config file

## Data Flow

1. Application starts and loads configuration from `config.properties` and environment variables
2. Creates OAuth2 credential (anonymous if no token provided)
3. Initializes Twitch client and registers event handlers
4. Connects to specified Twitch channel
5. Listens for chat events and displays formatted messages
6. Monitors connection health and auto-reconnects if needed
7. User can quit gracefully with 'q' command

## External Dependencies

**Core Dependencies:**
- `twitch4j-chat` (1.19.0) - Twitch chat integration
- `slf4j-api` (1.7.36) - Logging interface
- `logback-classic` (1.2.12) - Logging implementation

**Build Tools:**
- Maven with compiler and exec plugins
- Java 21 runtime environment

## Configuration

**Required Settings:**
- `TWITCH_CHANNEL` environment variable or `twitch.channel.name` in config.properties

**Optional Settings:**
- `TWITCH_ACCESS_TOKEN` environment variable or `twitch.access.token` in config.properties (for private channels)

## Deployment Strategy

**Local Development:**
- Run using `./run.sh` script which sets up Java and Maven environment
- Configuration through `config.properties` file
- Logs output to console and `logs/` directory

**Environment Setup:**
- Java 21 installation required
- Maven 3.9.4 for dependency management
- No external database or web server needed

## Recent Changes

**January 15, 2025:**
- Set up complete Java application for Twitch chat reading
- Configured Maven build system with all required dependencies
- Created proper environment setup script for Java and Maven
- Application successfully starts and handles configuration validation

---

**Current Status**: Application is running and ready for channel configuration to start reading Twitch chat messages.