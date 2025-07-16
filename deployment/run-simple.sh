#!/bin/bash

# Simple deployment script that doesn't try to install packages
# Uses only what's available in the environment

set -e

echo "[SIMPLE-DEPLOY] === Simple Deployment ==="
echo "[SIMPLE-DEPLOY] Timestamp: $(date)"

# Set up Java environment
echo "[SIMPLE-DEPLOY] Setting up Java environment..."

# Try to find and set JAVA_HOME
if [ -n "$JAVA_HOME" ] && [ -f "$JAVA_HOME/bin/java" ]; then
    echo "[SIMPLE-DEPLOY] ✓ Using existing JAVA_HOME: $JAVA_HOME"
elif command -v java >/dev/null 2>&1; then
    # Derive JAVA_HOME from java command
    JAVA_CMD=$(command -v java)
    JAVA_HOME=$(dirname $(dirname $(readlink -f $JAVA_CMD)))
    export JAVA_HOME
    echo "[SIMPLE-DEPLOY] ✓ Derived JAVA_HOME: $JAVA_HOME"
else
    # Try to find Java in standard locations
    for java_dir in /usr/lib/jvm/java-11-* /usr/lib/jvm/default-java /opt/java/openjdk; do
        if [ -d "$java_dir" ] && [ -f "$java_dir/bin/java" ]; then
            export JAVA_HOME="$java_dir"
            echo "[SIMPLE-DEPLOY] ✓ Found Java at: $JAVA_HOME"
            break
        fi
    done
fi

# Ensure Java is in PATH
if [ -n "$JAVA_HOME" ]; then
    export PATH="$JAVA_HOME/bin:$PATH"
fi

# Verify Java is working
if command -v java >/dev/null 2>&1; then
    JAVA_VERSION=$(java -version 2>&1 | head -1)
    echo "[SIMPLE-DEPLOY] ✓ Java verified: $JAVA_VERSION"
else
    echo "[SIMPLE-DEPLOY] ERROR: Java setup failed"
    exit 1
fi

# Set up Maven
if [ -d "$PWD/maven" ]; then
    export PATH="$PWD/maven/bin:$PATH"
    echo "[SIMPLE-DEPLOY] ✓ Using project Maven"
elif command -v mvn >/dev/null 2>&1; then
    echo "[SIMPLE-DEPLOY] ✓ Using system Maven"
else
    echo "[SIMPLE-DEPLOY] ERROR: Maven not found"
    exit 1
fi

# Set environment variables
export SERVER_PORT=${PORT:-5000}
export SPRING_PROFILES_ACTIVE=production

echo "[SIMPLE-DEPLOY] Server will start on port: $SERVER_PORT"

# Check if we have a pre-built JAR
JAR_FILE="target/twitch-chat-reader-1.0.0.jar"
if [ ! -f "$JAR_FILE" ]; then
    JAR_FILE="target/twitch-chat-reader-1.0.jar"
fi

if [ -f "$JAR_FILE" ]; then
    echo "[SIMPLE-DEPLOY] ✓ Found pre-built JAR: $JAR_FILE"
    echo "[SIMPLE-DEPLOY] Starting application..."
    exec java -jar "$JAR_FILE" --server.port=$SERVER_PORT
else
    echo "[SIMPLE-DEPLOY] No pre-built JAR found, building and running..."
    echo "[SIMPLE-DEPLOY] Starting with Spring Boot Maven plugin..."
    exec mvn spring-boot:run -Dspring-boot.run.arguments=--server.port=$SERVER_PORT
fi