#!/bin/bash

# Spring Boot Twitch Chat Reader Startup Script with Enhanced Error Handling
set -e  # Exit on any error

echo "=== Spring Boot Twitch Chat Reader - Enhanced Startup ==="

# Set up Java environment (runtime detection)
echo "Setting up Java runtime environment..."

# Check if java command is already available
if command -v java &> /dev/null; then
    JAVA_COMMAND_PATH=$(command -v java)
    JAVA_HOME=$(dirname $(dirname "$JAVA_COMMAND_PATH"))
    echo "✓ Found Java command in PATH: $JAVA_COMMAND_PATH"
else
    # Comprehensive Java detection
    JAVA_HOME=""
    echo "Searching for Java installations..."
    
    # Check Nix store (Replit environment)
    if [ -d "/nix/store" ]; then
        echo "Checking Nix store for Java installations..."
        NIX_JDK_PATHS=$(ls -d /nix/store/*jdk* /nix/store/*adoptopenjdk* /nix/store/*openjdk* 2>/dev/null || echo "")
        if [ -n "$NIX_JDK_PATHS" ]; then
            echo "Found potential Java installations:"
            for path in $NIX_JDK_PATHS; do
                echo "  Checking: $path"
                if [ -d "$path" ] && [ -f "$path/bin/java" ]; then
                    JAVA_HOME="$path"
                    echo "✓ Selected Java at: $JAVA_HOME"
                    break
                elif [ -d "$path" ]; then
                    echo "  Directory exists but no java binary found"
                fi
            done
        else
            echo "No JDK directories found in Nix store"
        fi
    fi
    
    # Check standard locations
    if [ -z "$JAVA_HOME" ]; then
        STANDARD_PATHS="/usr/lib/jvm/java-11-openjdk /usr/lib/jvm/default-java /opt/java/openjdk"
        for path in $STANDARD_PATHS; do
            if [ -d "$path" ] && [ -f "$path/bin/java" ]; then
                JAVA_HOME="$path"
                echo "✓ Found Java at: $JAVA_HOME"
                break
            fi
        done
    fi
    
    # Check portable Java from build script
    if [ -z "$JAVA_HOME" ] && [ -d "$PWD/java" ] && [ -f "$PWD/java/bin/java" ]; then
        JAVA_HOME="$PWD/java"
        echo "✓ Found portable Java at: $JAVA_HOME"
    fi
    
    if [ -z "$JAVA_HOME" ]; then
        echo "ERROR: Java runtime not found."
        echo "Please ensure Java is installed or run the build script first."
        exit 1
    fi
    
    export JAVA_HOME
    export PATH=$JAVA_HOME/bin:$PATH
fi

# Verify Java runtime
if ! command -v java &> /dev/null; then
    echo "ERROR: Java command not available after setup"
    echo "JAVA_HOME: $JAVA_HOME"
    echo "PATH: $PATH"
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | head -1)
echo "✓ Java runtime verified: $JAVA_VERSION"
echo ""

# Set deployment environment variables
export SERVER_PORT=${PORT:-5000}
export SPRING_PROFILES_ACTIVE=production

echo "Runtime Configuration:"
echo "- Java Home: $JAVA_HOME"
echo "- Server Port: $SERVER_PORT"
echo "- Spring Profile: $SPRING_PROFILES_ACTIVE"
echo ""

# Check for pre-built JAR (build should be done separately)
echo "Checking for pre-built JAR file..."

# Check if JAR was built successfully
JAR_FILE="target/twitch-chat-reader-1.0.0.jar"
if [ ! -f "$JAR_FILE" ]; then
    echo "ERROR: JAR file not found at $JAR_FILE"
    echo "Target directory contents:"
    ls -la target/ 2>/dev/null || echo "Target directory does not exist"
    echo "This suggests the build step was not completed."
    echo "Please ensure the build script has been run first."
    exit 1
fi

echo "✓ JAR file built successfully: $JAR_FILE"
echo "Starting Spring Boot application on port $SERVER_PORT..."

# Start the application with optimized JVM settings
exec java \
    -Xmx512m \
    -Xms256m \
    -XX:+UseG1GC \
    -XX:MaxGCPauseMillis=200 \
    -Dserver.port=$SERVER_PORT \
    -Dspring.profiles.active=$SPRING_PROFILES_ACTIVE \
    -Djava.security.egd=file:/dev/./urandom \
    -jar "$JAR_FILE"