#!/bin/bash

# Simple Replit runner that uses system Java without building
# Assumes the JAR has already been built

set -e

echo "[RUN-REPLIT] === Starting Twitch Chat Reader ==="
echo "[RUN-REPLIT] Timestamp: $(date)"



echo "[RUN-REPLIT] Using Java: $JAVA_HOME"

# Check for existing JAR file
JAR_FILE="target/twitch-chat-reader-1.0.0.jar"
if [ ! -f "$JAR_FILE" ]; then
    JAR_FILE="target/twitch-chat-reader-1.0.jar"
fi

if [ ! -f "$JAR_FILE" ]; then
    echo "[RUN-REPLIT] ERROR: JAR file not found. Building first..."
    export PATH="$PWD/maven/bin:$PATH"
    mvn clean package -DskipTests -q
    if [ ! -f "$JAR_FILE" ]; then
        echo "[RUN-REPLIT] ERROR: Build failed"
        exit 1
    fi
fi

echo "[RUN-REPLIT] ✓ JAR file found: $JAR_FILE"

# Start the application
echo "[RUN-REPLIT] Starting Spring Boot application..."
exec java -jar "$JAR_FILE" --server.port=5000