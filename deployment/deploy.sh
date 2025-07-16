#!/bin/bash

# Deployment script for Replit production environment
# Handles Java detection and installation for deployment

set -e

echo "[DEPLOY] === Deployment Setup ==="
echo "[DEPLOY] Timestamp: $(date)"

# Function to check if Java is available
check_java() {
    if command -v java >/dev/null 2>&1; then
        JAVA_VERSION=$(java -version 2>&1 | head -1)
        echo "[DEPLOY] ✓ Java found: $JAVA_VERSION"
        return 0
    fi
    return 1
}

# Function to set up Java environment
setup_java() {
    echo "[DEPLOY] Setting up Java environment..."
    
    # Check if Java is already available
    if check_java; then
        return 0
    fi
    
    # Try Nix store first (Replit environment)
    if [ -d "/nix/store" ]; then
        echo "[DEPLOY] Checking Nix store for Java..."
        NIX_JAVA_PATHS=$(find /nix/store -maxdepth 1 -name "*jdk*" -o -name "*openjdk*" 2>/dev/null | head -5)
        for java_path in $NIX_JAVA_PATHS; do
            if [ -f "$java_path/bin/java" ]; then
                export JAVA_HOME="$java_path"
                export PATH="$JAVA_HOME/bin:$PATH"
                echo "[DEPLOY] ✓ Using Nix Java at: $JAVA_HOME"
                return 0
            fi
        done
    fi
    
    # Try to find Java in common locations
    JAVA_LOCATIONS=(
        "/usr/lib/jvm/java-11-openjdk/bin/java"
        "/usr/lib/jvm/java-11-openjdk-amd64/bin/java"
        "/usr/lib/jvm/default-java/bin/java"
        "/opt/java/openjdk/bin/java"
    )
    
    for java_path in "${JAVA_LOCATIONS[@]}"; do
        if [ -f "$java_path" ]; then
            JAVA_HOME=$(dirname $(dirname "$java_path"))
            export JAVA_HOME
            export PATH="$JAVA_HOME/bin:$PATH"
            echo "[DEPLOY] ✓ Using Java at: $JAVA_HOME"
            return 0
        fi
    done
    
    # If no Java found, try using system-provided Java
    echo "[DEPLOY] Trying to find any available Java..."
    if command -v java >/dev/null 2>&1; then
        echo "[DEPLOY] ✓ Found Java in PATH"
        return 0
    fi
    
    echo "[DEPLOY] ERROR: No Java installation found"
    echo "[DEPLOY] Available locations checked:"
    echo "[DEPLOY] - Nix store: /nix/store/*jdk*"
    echo "[DEPLOY] - Standard locations: /usr/lib/jvm/*"
    echo "[DEPLOY] - System PATH"
    exit 1
}

# Set up Maven
setup_maven() {
    if [ -d "$PWD/maven" ]; then
        export PATH="$PWD/maven/bin:$PATH"
        echo "[DEPLOY] ✓ Using project Maven: $PWD/maven"
    elif command -v mvn >/dev/null 2>&1; then
        echo "[DEPLOY] ✓ Using system Maven: $(which mvn)"
    else
        echo "[DEPLOY] ERROR: Maven not found"
        exit 1
    fi
}

# Main deployment process
main() {
    setup_java
    setup_maven
    
    # Verify setup
    if ! check_java; then
        echo "[DEPLOY] ERROR: Java setup failed"
        exit 1
    fi
    
    MVN_VERSION=$(mvn -version 2>&1 | head -1)
    echo "[DEPLOY] ✓ Maven verified: $MVN_VERSION"
    
    # Build the application
    echo "[DEPLOY] Building application..."
    mvn clean package -DskipTests -q
    
    # Find the JAR file
    JAR_FILE="target/twitch-chat-reader-1.0.0.jar"
    if [ ! -f "$JAR_FILE" ]; then
        JAR_FILE="target/twitch-chat-reader-1.0.jar"
    fi
    
    if [ ! -f "$JAR_FILE" ]; then
        echo "[DEPLOY] ERROR: JAR file not found"
        exit 1
    fi
    
    echo "[DEPLOY] ✓ JAR file ready: $JAR_FILE"
    
    # Start the application
    echo "[DEPLOY] Starting application..."
    exec java -jar "$JAR_FILE" --server.port=${PORT:-5000}
}

# Run main function
main "$@"