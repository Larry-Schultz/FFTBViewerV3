#!/bin/bash

# Optimized Spring Boot startup script for Replit Autoscale deployment
# This script is designed to work specifically with Autoscale deployment type

set -e  # Exit on any error

echo "=== Spring Boot Twitch Chat Reader - Autoscale Deployment ==="

# Set up Java environment for Replit
export JAVA_HOME=$(ls -d /nix/store/*jdk* | head -1 2>/dev/null || echo "/usr/lib/jvm/java-11-openjdk")
export PATH=$JAVA_HOME/bin:$PWD/maven/bin:$PATH

# Verify Java environment
echo "Java Home: $JAVA_HOME"
if command -v java &> /dev/null; then
    echo "Java version: $(java -version 2>&1 | head -1)"
else
    echo "ERROR: Java not found in PATH"
    exit 1
fi

# Verify Maven
if command -v mvn &> /dev/null; then
    echo "Maven version: $(mvn -version | head -1)"
else
    echo "ERROR: Maven not found in PATH"
    exit 1
fi

# Set deployment-specific environment variables
export SERVER_PORT=${PORT:-5000}
export SPRING_PROFILES_ACTIVE=production

# Build the application (skip tests for faster deployment)
echo "Building Spring Boot application for deployment..."
mvn clean package -DskipTests -Dmaven.test.skip=true -q

# Check if JAR was built successfully
JAR_FILE="target/twitch-chat-reader-1.0.0.jar"
if [ ! -f "$JAR_FILE" ]; then
    echo "ERROR: JAR file not found at $JAR_FILE"
    echo "Build may have failed. Checking Maven status..."
    mvn --version
    exit 1
fi

echo "JAR file built successfully: $JAR_FILE"
echo "Starting Spring Boot application on port $SERVER_PORT..."

# Start the application with optimized JVM settings for Autoscale
exec java \
    -Xmx512m \
    -Xms256m \
    -XX:+UseG1GC \
    -XX:MaxGCPauseMillis=200 \
    -Dserver.port=$SERVER_PORT \
    -Dspring.profiles.active=$SPRING_PROFILES_ACTIVE \
    -Djava.security.egd=file:/dev/./urandom \
    -jar "$JAR_FILE"