#!/bin/bash

# Spring Boot Build Script
# Handles all build-related tasks including environment setup and compilation

set -e  # Exit on any error

LOG_PREFIX="[BUILD]"
echo "$LOG_PREFIX === Spring Boot Build Process ==="
echo "$LOG_PREFIX Timestamp: $(date)"

# Function to log with timestamp
log() {
    echo "$LOG_PREFIX $1"
}

# Set up Java environment
log "Setting up Java environment..."

# Enhanced Java detection
if command -v java >/dev/null 2>&1; then
    JAVA_COMMAND_PATH=$(command -v java)
    JAVA_HOME=$(dirname $(dirname "$JAVA_COMMAND_PATH"))
    log "✓ Found Java command in PATH: $JAVA_COMMAND_PATH"
    log "✓ Derived JAVA_HOME: $JAVA_HOME"
else
    log "Java command not found in PATH, searching for installations..."
    
    # Check Nix store first - improved detection
    JAVA_HOME=""
    if [ -d "/nix/store" ]; then
        log "Checking Nix store for Java installations..."
        NIX_JDK_PATHS=$(find /nix/store -maxdepth 1 -name "*jdk*" -o -name "*adoptopenjdk*" -o -name "*openjdk*" 2>/dev/null | sort -V | tail -5)
        if [ -n "$NIX_JDK_PATHS" ]; then
            log "Found potential Java installations:"
            for path in $NIX_JDK_PATHS; do
                log "  Checking: $path"
                if [ -d "$path" ] && [ -f "$path/bin/java" ]; then
                    JAVA_HOME="$path"
                    log "✓ Selected Java at: $JAVA_HOME"
                    break
                elif [ -d "$path" ]; then
                    log "  Directory exists, checking contents..."
                    if [ -d "$path/bin" ]; then
                        log "  Bin directory found, checking for java executable..."
                        ls -la "$path/bin/java*" 2>/dev/null | head -3
                    else
                        log "  No bin directory found"
                    fi
                fi
            done
        else
            log "No JDK directories found in Nix store"
        fi
    fi
    
    # Check standard locations if Nix didn't work
    if [ -z "$JAVA_HOME" ]; then
        STANDARD_PATHS="/usr/lib/jvm/java-11-openjdk /usr/lib/jvm/default-java /opt/java/openjdk"
        for path in $STANDARD_PATHS; do
            if [ -d "$path" ]; then
                JAVA_HOME="$path"
                log "✓ Found Java at: $JAVA_HOME"
                break
            fi
        done
    fi
    
    # Download portable JDK if still no Java found
    if [ -z "$JAVA_HOME" ] || [ ! -d "$JAVA_HOME" ]; then
        log "No Java installation found - downloading portable OpenJDK 11..."
        PORTABLE_JAVA_DIR="$PWD/java"
        mkdir -p "$PORTABLE_JAVA_DIR"
        
        OPENJDK_URL="https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz"
        log "Downloading from: $OPENJDK_URL"
        
        if command -v wget >/dev/null 2>&1; then
            wget -q "$OPENJDK_URL" -O openjdk.tar.gz
        elif command -v curl >/dev/null 2>&1; then
            curl -sL "$OPENJDK_URL" -o openjdk.tar.gz
        else
            log "ERROR: Neither wget nor curl available for Java download"
            exit 1
        fi
        
        tar -xzf openjdk.tar.gz --strip-components=1 -C "$PORTABLE_JAVA_DIR"
        rm openjdk.tar.gz
        JAVA_HOME="$PORTABLE_JAVA_DIR"
        log "✓ Portable Java installed at: $JAVA_HOME"
    fi
fi

export JAVA_HOME
export PATH="$JAVA_HOME/bin:$PATH"

# Verify Java installation
if ! command -v java >/dev/null 2>&1; then
    log "ERROR: Java command not available after setup"
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | head -1)
log "✓ Java verified: $JAVA_VERSION"

# Set up Maven
log "Setting up Maven..."
MAVEN_HOME="$PWD/maven"
export PATH="$MAVEN_HOME/bin:$PATH"

# Download Maven if not present
if [ ! -d "$MAVEN_HOME" ]; then
    log "Maven not found, downloading Maven 3.9.4..."
    mkdir -p "$MAVEN_HOME"
    MAVEN_URL="https://archive.apache.org/dist/maven/maven-3/3.9.4/binaries/apache-maven-3.9.4-bin.tar.gz"
    
    if command -v wget >/dev/null 2>&1; then
        wget -q "$MAVEN_URL" -O maven.tar.gz
    elif command -v curl >/dev/null 2>&1; then
        curl -sL "$MAVEN_URL" -o maven.tar.gz
    else
        log "ERROR: Neither wget nor curl available for Maven download"
        exit 1
    fi
    
    tar -xzf maven.tar.gz --strip-components=1 -C "$MAVEN_HOME"
    rm maven.tar.gz
    log "✓ Maven downloaded and extracted"
fi

# Verify Maven
if ! command -v mvn >/dev/null 2>&1; then
    log "ERROR: Maven command not available"
    exit 1
fi

MAVEN_VERSION=$(mvn -version | head -1)
log "✓ Maven verified: $MAVEN_VERSION"

# Verify project structure
if [ ! -f "pom.xml" ]; then
    log "ERROR: pom.xml not found in current directory"
    log "Current directory: $(pwd)"
    exit 1
fi

log "✓ Project structure verified"

# Build the application
log "Building Spring Boot application..."
BUILD_START=$(date +%s)

if ! mvn clean package -DskipTests -Dmaven.test.skip=true -q; then
    log "ERROR: Maven build failed"
    log "Build diagnostics:"
    log "  - Java version: $(java -version 2>&1 | head -1)"
    log "  - Maven version: $(mvn -version | head -1)"
    log "  - Project directory: $(pwd)"
    log "Attempting verbose build for debugging..."
    mvn clean package -DskipTests -X | tail -50
    exit 1
fi

BUILD_END=$(date +%s)
BUILD_TIME=$((BUILD_END - BUILD_START))
log "✓ Build completed in ${BUILD_TIME} seconds"

# Verify JAR file
JAR_FILE="target/twitch-chat-reader-1.0.0.jar"
if [ ! -f "$JAR_FILE" ]; then
    log "ERROR: JAR file not found at $JAR_FILE"
    log "Target directory contents:"
    ls -la target/ 2>/dev/null || log "Target directory does not exist"
    exit 1
fi

JAR_SIZE=$(ls -lh "$JAR_FILE" | awk '{print $5}')
log "✓ JAR built successfully: $JAR_FILE ($JAR_SIZE)"

log "=== Build Process Complete ==="