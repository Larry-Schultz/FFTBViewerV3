#!/bin/bash

# Enhanced Spring Boot Deployment Script for Replit
# Designed specifically for deployment environments with comprehensive error handling

set -e  # Exit on any error

echo "=== Spring Boot Twitch Chat Reader - Deployment Script ==="
echo "Timestamp: $(date)"

# Function to log with timestamp
log() {
    echo "[$(date '+%H:%M:%S')] $1"
}

# Function to check command availability
check_command() {
    if command -v "$1" &> /dev/null; then
        log "✓ $1 found"
        return 0
    else
        log "✗ $1 not found"
        return 1
    fi
}

# Set up Java environment with multiple fallback options
log "Setting up Java environment..."
JAVA_CANDIDATES=(
    "$(ls -d /nix/store/*jdk* | head -1 2>/dev/null || echo '')"
    "/usr/lib/jvm/java-11-openjdk"
    "/usr/lib/jvm/default-java"
    "/opt/java/openjdk"
)

for java_path in "${JAVA_CANDIDATES[@]}"; do
    if [ -n "$java_path" ] && [ -d "$java_path" ]; then
        export JAVA_HOME="$java_path"
        log "Trying Java at: $JAVA_HOME"
        break
    fi
done

if [ -z "$JAVA_HOME" ] || [ ! -d "$JAVA_HOME" ]; then
    log "ERROR: No valid Java installation found"
    log "Searched paths:"
    for path in "${JAVA_CANDIDATES[@]}"; do
        log "  - $path"
    done
    exit 1
fi

export PATH="$JAVA_HOME/bin:$PATH"

# Verify Java
if ! check_command java; then
    log "ERROR: Java command not available after setting JAVA_HOME"
    log "JAVA_HOME: $JAVA_HOME"
    log "PATH: $PATH"
    exit 1
fi

log "Java version: $(java -version 2>&1 | head -1)"

# Set up Maven environment
log "Setting up Maven environment..."
MAVEN_HOME="$PWD/maven"
export PATH="$MAVEN_HOME/bin:$PATH"

# Download Maven if not present
if [ ! -d "$MAVEN_HOME" ]; then
    log "Maven not found. Downloading Maven 3.9.4..."
    mkdir -p "$MAVEN_HOME"
    MAVEN_URL="https://archive.apache.org/dist/maven/maven-3/3.9.4/binaries/apache-maven-3.9.4-bin.tar.gz"
    
    if command -v wget &> /dev/null; then
        wget -q "$MAVEN_URL" -O maven.tar.gz
    elif command -v curl &> /dev/null; then
        curl -sL "$MAVEN_URL" -o maven.tar.gz
    else
        log "ERROR: Neither wget nor curl found for downloading Maven"
        exit 1
    fi
    
    tar -xzf maven.tar.gz --strip-components=1 -C "$MAVEN_HOME"
    rm maven.tar.gz
    log "✓ Maven downloaded and extracted"
fi

# Verify Maven
if ! check_command mvn; then
    log "ERROR: Maven command not available"
    log "Maven path: $MAVEN_HOME/bin"
    log "PATH: $PATH"
    exit 1
fi

log "Maven version: $(mvn -version | head -1)"

# Set deployment environment variables
export SERVER_PORT="${PORT:-5000}"
export SPRING_PROFILES_ACTIVE="production"

log "Deployment Configuration:"
log "  - Java Home: $JAVA_HOME"
log "  - Maven Home: $MAVEN_HOME"
log "  - Server Port: $SERVER_PORT"
log "  - Spring Profile: $SPRING_PROFILES_ACTIVE"

# Verify project structure
if [ ! -f "pom.xml" ]; then
    log "ERROR: pom.xml not found in current directory"
    log "Current directory: $(pwd)"
    log "Directory contents:"
    ls -la
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
    log "  - pom.xml exists: $([ -f pom.xml ] && echo 'Yes' || echo 'No')"
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

JAR_SIZE=$(stat -f%z "$JAR_FILE" 2>/dev/null || stat -c%s "$JAR_FILE" 2>/dev/null || echo "unknown")
log "✓ JAR file ready: $JAR_FILE (${JAR_SIZE} bytes)"

# Start the application
log "Starting Spring Boot application..."
log "Application will be available on port $SERVER_PORT"

# Use exec to replace the shell process
exec java \
    -Xmx512m \
    -Xms256m \
    -XX:+UseG1GC \
    -XX:MaxGCPauseMillis=200 \
    -XX:+ExitOnOutOfMemoryError \
    -Dserver.port="$SERVER_PORT" \
    -Dspring.profiles.active="$SPRING_PROFILES_ACTIVE" \
    -Djava.security.egd=file:/dev/./urandom \
    -Dfile.encoding=UTF-8 \
    -jar "$JAR_FILE"