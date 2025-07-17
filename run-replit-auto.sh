#!/bin/bash

# Optimized run script for Replit with automatic Java detection and download
# This script prioritizes existing Java installations but can download if needed

set -e

LOG_PREFIX="[REPLIT-AUTO]"
log() {
    echo "$LOG_PREFIX $1" >&2
}

log "=== Spring Boot Auto-Setup for Replit ==="
log "Timestamp: $(date)"

# Function to find Java in Nix store
find_nix_java() {
    # Try to find any AdoptOpenJDK installation
    for java_path in /nix/store/*adoptopenjdk*bin*; do
        if [ -d "$java_path" ] && [ -f "$java_path/bin/java" ]; then
            echo "$java_path"
            return 0
        fi
    done
    
    # Fallback to any JDK installation
    for java_path in /nix/store/*jdk*; do
        if [ -d "$java_path" ] && [ -f "$java_path/bin/java" ]; then
            echo "$java_path"
            return 0
        fi
    done
    
    return 1
}

# Function to download Java if not found
download_java() {
    log "Downloading Java JDK 11 (Temurin)..."
    JAVA_DIR="$PWD/java-downloaded"
    
    mkdir -p "$JAVA_DIR"
    
    # Download smaller JRE version for faster download
    if command -v curl >/dev/null 2>&1; then
        log "Downloading with curl..."
        curl -L -o "$JAVA_DIR/openjdk-11.tar.gz" \
            "https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.21%2B9/OpenJDK11U-jre_x64_linux_hotspot_11.0.21_9.tar.gz"
    else
        log "ERROR: curl not available for download"
        return 1
    fi
    
    # Extract
    cd "$JAVA_DIR"
    tar -xzf openjdk-11.tar.gz --strip-components=1
    rm -f openjdk-11.tar.gz
    cd "$PWD"
    
    if [ -f "$JAVA_DIR/bin/java" ]; then
        log "✓ Java downloaded successfully"
        echo "$JAVA_DIR"
        return 0
    else
        log "ERROR: Java download failed"
        return 1
    fi
}

# Main Java detection logic
log "Detecting Java installation..."

JAVA_HOME=""

# 1. Check Nix store first (fastest)
if JAVA_HOME=$(find_nix_java); then
    log "✓ Found Java in Nix store: $JAVA_HOME"
    
# 2. Check if we already downloaded Java
elif [ -d "$PWD/java-downloaded" ] && [ -f "$PWD/java-downloaded/bin/java" ]; then
    JAVA_HOME="$PWD/java-downloaded"
    log "✓ Found previously downloaded Java: $JAVA_HOME"
    
# 3. Check system locations
elif [ -d "/usr/lib/jvm/java-11-openjdk-amd64" ]; then
    JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
    log "✓ Found system Java: $JAVA_HOME"
    
# 4. Download Java as last resort
else
    log "No Java found, downloading..."
    if JAVA_HOME=$(download_java); then
        log "✓ Using downloaded Java: $JAVA_HOME"
    else
        log "ERROR: Failed to set up Java"
        exit 1
    fi
fi

# Set environment
export JAVA_HOME
export PATH="$JAVA_HOME/bin:$PWD/maven/bin:$PATH"

# Verify Java works
if ! command -v java >/dev/null 2>&1; then
    log "ERROR: Java not accessible after setup"
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | head -1)
log "✓ Java ready: $JAVA_VERSION"

# Check for JAR file
JAR_FILE="target/twitch-chat-reader-1.0.0.jar"
if [ ! -f "$JAR_FILE" ]; then
    JAR_FILE="target/twitch-chat-reader-1.0.jar"
fi

# Start application
export SERVER_PORT=${PORT:-5000}
log "Starting application on port $SERVER_PORT..."

if [ -f "$JAR_FILE" ]; then
    log "Using existing JAR: $JAR_FILE"
    exec java -jar "$JAR_FILE" --server.port=$SERVER_PORT
else
    log "Building and running with Maven..."
    exec mvn spring-boot:run -Dspring-boot.run.arguments=--server.port=$SERVER_PORT
fi