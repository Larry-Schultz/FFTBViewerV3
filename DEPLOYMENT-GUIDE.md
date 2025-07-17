# Deployment Guide - Twitch Chat Reader

## Overview
This guide covers all deployment options for the Spring Boot Twitch Chat Reader application. The project has been optimized for reliable deployment across different environments with comprehensive Java detection and fallback mechanisms.

## Deployment Scripts Available

### 1. `run` - Main Production Script
**Best for:** Production deployments, comprehensive environment setup
```bash
./run
```
**Features:**
- Comprehensive Java detection (Nix store, system paths, package managers)
- Automatic Java installation via package managers (apt, yum, nix-env)
- Maven auto-setup if not present
- Detailed logging and diagnostics
- Graceful error handling with fallback options

### 2. `run-replit-auto.sh` - Replit-Optimized Script
**Best for:** Replit deployments, faster startup
```bash
./run-replit-auto.sh
```
**Features:**
- Prioritizes Replit Nix store Java installations
- Automatic Java download as fallback
- Optimized for Replit environment
- Minimal dependencies
- Fast startup time

### 3. `run-simple.sh` - Lightweight Script
**Best for:** Simple environments, quick testing
```bash
./run-simple.sh
```
**Features:**
- Uses existing Java installation
- Minimal setup requirements
- Fast execution
- Basic error handling

## Environment Requirements

### Minimum Requirements
- Java 11 or higher
- Maven 3.6+ (auto-installed if needed)
- PostgreSQL database (provided by Replit)
- Internet connection for Twitch API

### Recommended Environment Variables
```bash
# Required
export TWITCH_CHANNEL=fftbattleground

# Optional (for authenticated features)
export TWITCH_ACCESS_TOKEN=your_token_here
export TWITCH_USERNAME=your_bot_username

# Server configuration
export SERVER_PORT=5000
export DATABASE_URL=your_postgres_url
```

## Deployment Steps

### For Replit Deployment
1. **Use the optimized script:**
   ```bash
   ./run-replit-auto.sh
   ```

2. **Alternative workflow setup:**
   ```bash
   export JAVA_HOME=/nix/store/023zqb5jvvjhv5l1b0fzdaqxy8c7ilcl-adoptopenjdk-openj9-bin-11.0.11
   export PATH=$JAVA_HOME/bin:$PWD/maven/bin:$PATH
   mvn spring-boot:run -Dspring-boot.run.arguments=--server.port=5000
   ```

### For General Linux Environment
1. **Use the main script:**
   ```bash
   ./run
   ```

2. **Manual setup (if needed):**
   ```bash
   # Install Java
   sudo apt install openjdk-11-jdk
   
   # Set environment
   export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
   export PATH=$JAVA_HOME/bin:$PATH
   
   # Run application
   mvn spring-boot:run
   ```

## Troubleshooting Common Issues

### Java Not Found
**Solution:** Scripts will automatically attempt to install Java. If manual installation is needed:
```bash
# Ubuntu/Debian
sudo apt install openjdk-11-jdk

# RHEL/CentOS
sudo yum install java-11-openjdk-devel

# Replit (using Nix)
nix-env -iA nixpkgs.openjdk11
```

### Maven Not Found
**Solution:** Scripts will automatically download Maven 3.9.4 to the project directory if not found.

### Permission Errors
**Solution:** Ensure scripts are executable:
```bash
chmod +x run run-replit-auto.sh run-simple.sh
```

### Database Connection Issues
**Solution:** Verify PostgreSQL is running and DATABASE_URL is set correctly.

## Performance Optimization

### For Production Deployment
```bash
# Set JVM options for production
export JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseG1GC -server"

# Enable production profile
export SPRING_PROFILES_ACTIVE=production
```

### For Development
```bash
# Use development profile
export SPRING_PROFILES_ACTIVE=default

# Enable debug logging
export LOGGING_LEVEL_COM_TWITCHCHAT=DEBUG
```

## Application Features

### Web Interface
- **URL:** http://localhost:5000
- **Features:** Real-time chat display, song playlist, search functionality
- **WebSocket:** Auto-reconnecting real-time updates

### API Endpoints
- `/api/songs` - Song playlist with search/filter
- `/api/stats` - Play statistics
- `/ws` - WebSocket endpoint for real-time updates

### Database Features
- **PostgreSQL integration** with connection pooling
- **Automatic playlist sync** from FFT Battleground XML feed
- **Song play tracking** from Twitch chat messages
- **Duplicate prevention** with unique constraints

## Security Considerations

### API Keys
- Store sensitive tokens in environment variables
- Use Replit Secrets for TWITCH_ACCESS_TOKEN
- Never commit credentials to version control

### Database Security
- Use connection pooling (HikariCP)
- Prepared statements prevent SQL injection
- Database URL should use SSL in production

## Monitoring and Logging

### Application Logs
- Spring Boot integrated logging
- Real-time chat message logging
- Database operation tracking
- WebSocket connection monitoring

### Health Checks
- Spring Boot Actuator endpoints
- Database connection validation
- Twitch API connection status

## Deployment Verification

### Quick Health Check
```bash
# Check application is running
curl http://localhost:5000/actuator/health

# Check WebSocket connection
curl -H "Upgrade: websocket" http://localhost:5000/ws

# Verify database connectivity
curl http://localhost:5000/api/songs?limit=1
```

### Expected Startup Sequence
1. Java environment detection/setup
2. Maven dependency resolution
3. Spring Boot application startup
4. Database connection establishment
5. Twitch chat client initialization
6. WebSocket server activation
7. Playlist synchronization
8. Ready for connections on port 5000

## Success Indicators
- ✅ "Started TwitchChatReaderApplication" in logs
- ✅ "Joined channel: fftbattleground" message
- ✅ "Tomcat started on port(s): 5000" confirmation
- ✅ Chat messages appearing in console
- ✅ Web interface accessible at http://localhost:5000
- ✅ Database showing song count updates

---

**Last Updated:** July 17, 2025
**Status:** Production Ready - All deployment methods tested and verified