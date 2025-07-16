#!/bin/bash

# Spring Boot Twitch Chat Reader Startup Script with Enhanced Error Handling
set -e  # Exit on any error

echo "=== Spring Boot Twitch Chat Reader - Enhanced Startup ==="

# Set up Java environment (minimal - just for running JAR)
echo "Setting up Java runtime environment..."
export JAVA_HOME=$(ls -d /nix/store/*jdk* | head -1 2>/dev/null || echo "/usr/lib/jvm/java-11-openjdk")
export PATH=$JAVA_HOME/bin:$PATH

# Verify Java runtime
if [ ! -d "$JAVA_HOME" ]; then
    echo "ERROR: JAVA_HOME directory not found: $JAVA_HOME"
    exit 1
fi

if ! command -v java &> /dev/null; then
    echo "ERROR: Java command not found in PATH"
    exit 1
fi

echo "✓ Java runtime found at: $JAVA_HOME"
JAVA_VERSION=$(java -version 2>&1 | head -1)
echo "✓ Java version: $JAVA_VERSION"
echo ""

# Set deployment environment variables
export SERVER_PORT=${PORT:-5000}
export SPRING_PROFILES_ACTIVE=production

echo "Runtime Configuration:"
echo "- Java Home: $JAVA_HOME"
echo "- Server Port: $SERVER_PORT"
echo "- Spring Profile: $SPRING_PROFILES_ACTIVE"
echo ""

# Check for pre-built JAR (build should be done separately)
echo "Checking for pre-built JAR file..."

# Check if JAR was built successfully
JAR_FILE="target/twitch-chat-reader-1.0.0.jar"
if [ ! -f "$JAR_FILE" ]; then
    echo "ERROR: JAR file not found at $JAR_FILE"
    echo "Target directory contents:"
    ls -la target/ 2>/dev/null || echo "Target directory does not exist"
    echo "This suggests the build step was not completed."
    echo "Please ensure the build script has been run first."
    exit 1
fi

echo "✓ JAR file built successfully: $JAR_FILE"
echo "Starting Spring Boot application on port $SERVER_PORT..."

# Start the application with optimized JVM settings
exec java \
    -Xmx512m \
    -Xms256m \
    -XX:+UseG1GC \
    -XX:MaxGCPauseMillis=200 \
    -Dserver.port=$SERVER_PORT \
    -Dspring.profiles.active=$SPRING_PROFILES_ACTIVE \
    -Djava.security.egd=file:/dev/./urandom \
    -jar "$JAR_FILE"