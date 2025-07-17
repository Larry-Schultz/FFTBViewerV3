#!/bin/bash

# Simplified run script for Replit deployment
# Direct Java execution without complex logic

set -e

echo "=== Simple Twitch Chat Reader Start ==="
echo "Timestamp: $(date)"

# Set up Java environment - use specific working path
echo "Setting up Java environment..."
JAVA_HOME="/nix/store/023zqb5jvvjhv5l1b0fzdaqxy8c7ilcl-adoptopenjdk-openj9-bin-11.0.11"

if [ ! -d "$JAVA_HOME" ] || [ ! -f "$JAVA_HOME/bin/java" ]; then
    echo "ERROR: Java not found at expected location: $JAVA_HOME"
    echo "Trying alternative detection..."
    JAVA_HOME=$(ls -d /nix/store/*adoptopenjdk*bin* | head -1)
    if [ ! -d "$JAVA_HOME" ] || [ ! -f "$JAVA_HOME/bin/java" ]; then
        echo "ERROR: No working Java installation found"
        exit 1
    fi
fi

export JAVA_HOME
export PATH="$JAVA_HOME/bin:$PWD/maven/bin:$PATH"

echo "Java Home: $JAVA_HOME"

# Verify Java is working
if ! command -v java >/dev/null 2>&1; then
    echo "ERROR: Java command not available"
    echo "PATH: $PATH"
    exit 1
fi

echo "Java Version: $(java -version 2>&1 | head -1)"

# Verify Maven is working
if ! command -v mvn >/dev/null 2>&1; then
    echo "ERROR: Maven command not available"
    echo "Maven Path: $PWD/maven/bin/mvn"
    ls -la "$PWD/maven/bin/" | head -5 || echo "Maven bin directory not found"
    exit 1
fi

echo "Maven Version: $(mvn -version 2>&1 | head -1)"

# Set server port
export SERVER_PORT=${PORT:-5000}
echo "Server Port: $SERVER_PORT"

# Look for existing JAR file
JAR_FILE="target/twitch-chat-reader-1.0.0.jar"
if [ ! -f "$JAR_FILE" ]; then
    JAR_FILE="target/twitch-chat-reader-1.0.jar"
fi

if [ -f "$JAR_FILE" ]; then
    echo "Found JAR: $JAR_FILE"
    echo "Starting application from JAR..."
    exec java -jar "$JAR_FILE" --server.port=$SERVER_PORT
else
    echo "No JAR found, building and running with Maven..."
    exec mvn spring-boot:run -Dspring-boot.run.arguments=--server.port=$SERVER_PORT
fi