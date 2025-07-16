# Twitch Chat Reader - Java Application

## Overview

A modern Spring Boot-powered Twitch chat reader application that monitors real-time chat messages from specific Twitch channels. Features both console output and a web interface with WebSocket support to display the last 50 chat messages in real-time. Built with Maven and designed for robust, authenticated Twitch integration with the 'fftbattleground' channel.

## User Preferences

Preferred communication style: Simple, everyday language.

## System Architecture

**Technology Stack:**
- Java 11 (OpenJDK)
- Spring Boot 2.7.18 framework (Web + WebSocket)
- Maven 3.9.4 for build management
- twitch4j library for Twitch API integration
- Spring Boot integrated logging
- Thymeleaf templating engine
- SockJS + STOMP for WebSocket communication

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
- `ChatEventHandler.java` - Spring component handling incoming chat events and WebSocket broadcasting
- `TwitchProperties.java` - Spring Boot configuration properties class for Twitch settings
- `ChatMessage.java` - Model class for chat message data
- `ChatMessageService.java` - Service managing the last 50 chat messages
- `WebSocketConfig.java` - WebSocket configuration for real-time communication
- `WebController.java` - Web controller serving the chat viewer interface
- `application.properties` - Spring Boot configuration file

**Features:**
- Real-time chat message display with timestamps (console + web)
- Modern web interface with Twitch-inspired design
- WebSocket-powered live message streaming
- Last 50 messages storage and display
- Auto-reconnection on connection loss
- Graceful shutdown with 'q' command
- Flexible configuration via environment variables or properties file
- Responsive design for mobile and desktop viewing

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
- `spring-boot-starter-web` - Web application support with embedded Tomcat
- `spring-boot-starter-websocket` - WebSocket support for real-time communication
- `spring-boot-starter-thymeleaf` - Templating engine for web pages
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
- Web interface available at http://localhost:5000
- Configuration through `application.properties` file
- Logs output to console using Spring Boot logging
- WebSocket endpoint at /ws for real-time communication

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
- Added complete web interface with Spring Boot Web starter
- Implemented WebSocket support for real-time message streaming
- Created modern Twitch-inspired web design with responsive layout
- Built ChatMessageService to manage last 50 messages display
- Added SockJS + STOMP for reliable WebSocket communication with auto-reconnect
- Successfully integrated real FFT Battleground playlist with 32,000+ songs via HTTP XML parsing
- Built custom XML parser for proprietary playlist format with proper song name cleaning and duration formatting
- Implemented robust search, filter, and sort functionality for massive song library
- Simplified playlist table to display only song titles and durations for cleaner interface
- Updated search and filtering to focus on song names with over 32,000 real tracks
- **Added real-time song play tracking system**: Monitors Twitch chat for "The track is now:" announcements
- **Removed duplicate songs**: Consolidated 60,500 records to 28,927 unique songs
- **Implemented occurrence field**: Tracks actual song plays from live chat, not XML duplicates
- **Created play statistics API**: Added endpoints for song stats and most-played songs
- **Integrated SongPlayTracker service**: Automatically updates occurrence counts from chat messages
- **Removed duplicate songs**: Deleted 3,502 duplicate entries, maintaining only unique songs (28,927 total)
- **Enhanced duplicate prevention**: Updated sync service to prevent future duplicates with better title checking

**January 15, 2025:**
- Set up complete Java application for Twitch chat reading
- Configured Maven build system with all required dependencies
- Created proper environment setup script for Java and Maven
- Application successfully starts and handles configuration validation

---

**Current Status**: Complete Spring Boot application with PostgreSQL database caching system running successfully on port 5000. Features authenticated Twitch access, real-time WebSocket communication, modern web UI displaying live chat messages from "fftbattleground" channel, and database-powered playlist system with scheduled XML sync, search functionality, and performance optimizations for 32,000+ songs from FFT Battleground's live music playlist. **NEW**: Real-time song play tracking system monitors chat for track announcements and maintains occurrence counts - currently tracking 506 total plays across 82 different songs with "Title Screen" being the most popular at 274 plays.

**July 15, 2025 - Deployment Configuration:**
- **FIXED AUTOSCALE DEPLOYMENT**: Resolved deployment issues by switching from Reserved VM to Autoscale
- **Updated run script**: Optimized for Autoscale with dynamic PORT binding and JVM tuning
- **Created AUTOSCALE-DEPLOYMENT.md**: Comprehensive guide for Autoscale deployment type
- **Enhanced production config**: Added server compression and Autoscale-specific settings
- **Deployment type change**: From Reserved VM (gce) to Autoscale for web applications
- **Performance optimization**: JVM settings tuned for 512MB memory limit and G1GC
- **Environment compatibility**: Supports both PORT variable (Autoscale) and fallback to 5000
- **Production profile**: Automatically activated with optimized logging and database pooling

**July 16, 2025 - Deployment Fixes Applied:**
- **ENHANCED start.sh SCRIPT**: Added comprehensive error handling for Java and Maven environment setup
- **Java environment validation**: Multiple fallback paths for Java installation detection
- **Maven auto-download**: Automatic Maven 3.9.4 download if not present in project directory
- **Build error diagnosis**: Detailed error reporting for failed Maven builds with troubleshooting info
- **JAR verification**: Enhanced checking for successful JAR file creation with size reporting
- **Created start-deployment.sh**: Alternative deployment script with advanced error handling and logging
- **FIXED PATH ISSUE**: Resolved "run command not found" by creating deployment-runner.sh in ~/.local/bin/run
- **PATH integration**: Both `sh -c run` and `sh -c "run "` deployment commands now work correctly
- **Smart project detection**: Deployment runner automatically finds project directory and executes start.sh
- **Multiple deployment options**: Created run-wrapper.sh and deployment-troubleshooting.md for comprehensive coverage
- **Enhanced error handling**: All deployment scenarios covered with fallback paths and detailed diagnostics
- **Executable permissions**: Ensured all deployment scripts have proper execution permissions
- **DEPLOYMENT VERIFIED**: Application successfully starts, connects to database, and joins Twitch channel ✅