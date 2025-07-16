#!/bin/bash

# Complete deployment solution for Replit
# This script handles both building and running the application

set -e

echo "[DEPLOY] === Complete Twitch Chat Reader Deployment ==="
echo "[DEPLOY] Timestamp: $(date)"

# Function to find Java
find_java() {
    # Check various Java locations
    for java_candidate in \
        ~/.nix-profile/bin/java \
        /nix/store/*/bin/java \
        /usr/lib/jvm/*/bin/java \
        $(which java 2>/dev/null); do
        
        if [[ -x "$java_candidate" ]]; then
            echo "$java_candidate"
            return 0
        fi
    done
    return 1
}

# Set server port
export SERVER_PORT=${PORT:-5000}
echo "[DEPLOY] Target port: $SERVER_PORT"

# Check for existing JAR
JAR_FILE=$(find target -name "*.jar" -not -name "*sources.jar" 2>/dev/null | head -1)

if [[ -n "$JAR_FILE" && -f "$JAR_FILE" ]]; then
    echo "[DEPLOY] Found existing JAR: $JAR_FILE"
    JAR_SIZE=$(ls -lh "$JAR_FILE" | awk '{print $5}')
    echo "[DEPLOY] JAR size: $JAR_SIZE"
    
    # Try to run with existing JAR
    if JAVA_CMD=$(find_java); then
        echo "[DEPLOY] Using Java: $JAVA_CMD"
        echo "[DEPLOY] Starting application from JAR..."
        exec "$JAVA_CMD" -jar "$JAR_FILE" --server.port=$SERVER_PORT
    else
        echo "[DEPLOY] No Java found for JAR execution, will build with Maven..."
    fi
fi

# No JAR or no Java found, use Maven approach
echo "[DEPLOY] Building and running with Maven..."

# Set up Java environment for Maven
if JAVA_HOME=$(find_java | head -1); then
    export JAVA_HOME=$(dirname $(dirname "$JAVA_HOME"))
    export PATH="$JAVA_HOME/bin:$PWD/maven/bin:$PATH"
    echo "[DEPLOY] Java environment: $JAVA_HOME"
else
    echo "[DEPLOY] ERROR: No Java installation found for Maven"
    exit 1
fi

echo "[DEPLOY] Maven: $PWD/maven/bin/mvn"
echo "[DEPLOY] Starting Maven Spring Boot run..."

# Run with Maven
exec mvn spring-boot:run -Dspring-boot.run.arguments=--server.port=$SERVER_PORT