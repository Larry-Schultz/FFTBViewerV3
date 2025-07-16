#!/bin/bash

# Complete deployment solution for Replit
# This script handles both building and running the application

set -e

echo "[DEPLOY] === Complete Twitch Chat Reader Deployment ==="
echo "[DEPLOY] Timestamp: $(date)"

# Function to find Java
find_java() {
    echo "[DEPLOY] Searching for Java installations..."
    
    # First check Nix profile
    if [[ -f ~/.nix-profile/bin/java ]]; then
        echo "[DEPLOY] Found Java in Nix profile"
        echo ~/.nix-profile/bin/java
        return 0
    fi
    
    # Search Nix store more thoroughly
    local nix_java=$(find /nix/store -maxdepth 2 -name "java" -type f -executable 2>/dev/null | head -1)
    if [[ -n "$nix_java" && -x "$nix_java" ]]; then
        echo "[DEPLOY] Found Java in Nix store: $nix_java"
        echo "$nix_java"
        return 0
    fi
    
    # Check PATH
    if command -v java >/dev/null 2>&1; then
        local java_path=$(which java)
        echo "[DEPLOY] Found Java in PATH: $java_path"
        echo "$java_path"
        return 0
    fi
    
    # Try system locations
    for java_path in /usr/lib/jvm/*/bin/java /usr/bin/java; do
        if [[ -x "$java_path" ]]; then
            echo "[DEPLOY] Found Java in system: $java_path"
            echo "$java_path"
            return 0
        fi
    done
    
    echo "[DEPLOY] No Java found"
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