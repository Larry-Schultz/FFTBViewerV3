#!/bin/bash

# Direct start script for deployment environments
# Robust Java detection and fallback installation

set -e

echo "[START] === Twitch Chat Reader Direct Start ==="
echo "[START] Timestamp: $(date)"

# Function to find Java installation
find_java() {
    echo "[START] Searching for Java installations..."
    
    # Check if java is in PATH first
    if command -v java >/dev/null 2>&1; then
        local java_binary=$(command -v java)
        local java_home=$(dirname $(dirname "$java_binary"))
        if [[ -f "$java_home/bin/java" ]]; then
            echo "[START] Found Java in PATH: $java_home"
            echo "$java_home"
            return 0
        fi
    fi
    
    # Try specific Nix store paths
    echo "[START] Checking Nix store for Java..."
    local nix_java_dirs=(
        $(find /nix/store -maxdepth 1 -type d -name "*openjdk*" 2>/dev/null | head -3)
        $(find /nix/store -maxdepth 1 -type d -name "*jdk*" 2>/dev/null | head -3)
    )
    
    for java_dir in "${nix_java_dirs[@]}"; do
        if [[ -f "$java_dir/bin/java" ]]; then
            echo "[START] Found Java in Nix store: $java_dir"
            echo "$java_dir"
            return 0
        fi
    done
    
    # Try system locations
    local system_paths=(
        "/usr/lib/jvm/java-11-openjdk"
        "/usr/lib/jvm/default-java"
        "/usr/lib/jvm/java-11-openjdk-amd64"
    )
    
    for java_path in "${system_paths[@]}"; do
        if [[ -f "$java_path/bin/java" ]]; then
            echo "[START] Found Java in system: $java_path"
            echo "$java_path"
            return 0
        fi
    done
    
    echo "[START] No Java installation found"
    return 1
}

# Set up Java environment with enhanced fallback
echo "[START] Setting up Java environment..."

# Try to add Nix profile to PATH (for deployed environment)
if [[ -f ~/.nix-profile/bin/java ]]; then
    export PATH="$HOME/.nix-profile/bin:$PATH"
    echo "[START] Added Nix profile to PATH"
fi

if JAVA_HOME=$(find_java); then
    export JAVA_HOME
    export PATH="$JAVA_HOME/bin:$PWD/maven/bin:$PATH"
    echo "[START] Java environment configured: $JAVA_HOME"
elif command -v java >/dev/null 2>&1; then
    export PATH="$PWD/maven/bin:$PATH"
    echo "[START] Using system Java: $(which java)"
    echo "[START] Java version: $(java -version 2>&1 | head -1)"
else
    echo "[START] No Java found, attempting to use pre-built JAR..."
    JAR_FILE=$(find target -name "*.jar" -not -name "*sources.jar" 2>/dev/null | head -1)
    if [[ -n "$JAR_FILE" && -f "$JAR_FILE" ]]; then
        echo "[START] Found pre-built JAR: $JAR_FILE"
        echo "[START] Will attempt direct JAR execution (requires system Java)"
    else
        echo "[START] ERROR: No Java installation and no pre-built JAR found"
        echo "[START] Available files in target/:"
        ls -la target/ 2>/dev/null || echo "No target directory"
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