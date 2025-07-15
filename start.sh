#!/bin/bash

# Spring Boot Twitch Chat Reader Startup Script
echo "=== Starting Twitch Chat Reader ==="

# Set up Java environment
export JAVA_HOME=$(ls -d /nix/store/*jdk* | head -1)
export PATH=$JAVA_HOME/bin:$PATH

# Set up Maven
export PATH=$PWD/maven/bin:$PATH

# Verify environment
echo "Java version:"
java -version
echo ""

echo "Maven version:"
mvn -version
echo ""

# Build the application (skip tests for faster deployment)
echo "Building Spring Boot application..."
mvn clean package -DskipTests

# Check if jar was built successfully
JAR_FILE="target/twitch-chat-reader-1.0.0.jar"
if [ ! -f "$JAR_FILE" ]; then
    echo "Error: JAR file not found at $JAR_FILE"
    echo "Build may have failed. Check Maven output above."
    exit 1
fi

# Start the Spring Boot application
echo "Starting Spring Boot application on port 5000..."
java -jar -Dserver.port=5000 "$JAR_FILE"