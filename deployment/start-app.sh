#!/bin/bash

# Direct start script for deployment environments
# Robust Java detection and fallback installation

set -e

echo "[START] === Twitch Chat Reader Direct Start ==="
echo "[START] Timestamp: $(date)"

# Function to find Java installation
find_java() {
    # Try multiple Java detection methods
    local java_candidates=(
        "/nix/store/*openjdk*"
        "/nix/store/*jdk*"
        "/usr/lib/jvm/java-11-openjdk"
        "/usr/lib/jvm/default-java"
    )
    
    for pattern in "${java_candidates[@]}"; do
        local java_path=$(find $(dirname "$pattern" 2>/dev/null || echo "/") -maxdepth 2 -name "$(basename "$pattern")" -type d 2>/dev/null | head -1)
        if [[ -n "$java_path" && -f "$java_path/bin/java" ]]; then
            echo "$java_path"
            return 0
        fi
    done
    
    # Check if java is in PATH
    if command -v java >/dev/null 2>&1; then
        local java_binary=$(command -v java)
        local java_home=$(dirname $(dirname "$java_binary"))
        if [[ -f "$java_home/bin/java" ]]; then
            echo "$java_home"
            return 0
        fi
    fi
    
    return 1
}

# Set up Java environment
if JAVA_HOME=$(find_java); then
    export JAVA_HOME
    export PATH="$JAVA_HOME/bin:$PWD/maven/bin:$PATH"
    echo "[START] Found Java: $JAVA_HOME"
else
    echo "[START] Java not found in system, checking for pre-built application..."
    # If no Java found, try to run pre-built JAR directly with system java
    if command -v java >/dev/null 2>&1; then
        export PATH="$PWD/maven/bin:$PATH"
        echo "[START] Using system Java: $(which java)"
    else
        echo "[START] ERROR: No Java installation found"
        exit 1
    fi
fi

echo "[START] Maven: $PWD/maven/bin/mvn"

# Set server port
export SERVER_PORT=${PORT:-5000}
echo "[START] Starting on port: $SERVER_PORT"

# Check if JAR already exists
JAR_FILE=$(find target -name "*.jar" -not -name "*sources.jar" 2>/dev/null | head -1)

if [[ -n "$JAR_FILE" && -f "$JAR_FILE" ]]; then
    echo "[START] Found pre-built JAR: $JAR_FILE"
    echo "[START] Starting application directly..."
    exec java -jar "$JAR_FILE" --server.port=$SERVER_PORT
else
    echo "[START] No pre-built JAR found, building with Maven..."
    # Run Spring Boot application with Maven
    exec mvn spring-boot:run -Dspring-boot.run.arguments=--server.port=$SERVER_PORT
fi