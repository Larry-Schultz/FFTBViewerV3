#!/bin/bash

# Fast build script for Replit deployment
# Assumes Java and Maven are already available in environment

set -e

LOG_PREFIX="[BUILD-FAST]"
log() {
    echo "$LOG_PREFIX $1" >&2
}

log "=== Fast Spring Boot Build Process ==="
log "Timestamp: $(date)"

# Quick Java check - use environment first, then find fastest available
if [ -n "$JAVA_HOME" ] && [ -f "$JAVA_HOME/bin/java" ]; then
    log "✓ Using JAVA_HOME: $JAVA_HOME"
elif command -v java >/dev/null 2>&1; then
    JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
    log "✓ Derived JAVA_HOME: $JAVA_HOME"
else
    log "Java not in PATH, searching Nix store..."
    # Fast single-pattern search for deployment speed
    JAVA_PATH=$(find /nix/store -maxdepth 1 -name "*openjdk*" -type d 2>/dev/null | head -1)
    if [ -n "$JAVA_PATH" ] && [ -f "$JAVA_PATH/bin/java" ]; then
        JAVA_HOME="$JAVA_PATH"
        log "✓ Found Java at: $JAVA_HOME"
    else
        log "ERROR: No Java installation found"
        log "Available in Nix store:"
        find /nix/store -maxdepth 1 -name "*jdk*" -o -name "*java*" 2>/dev/null | head -5
        exit 1
    fi
fi

export JAVA_HOME
export PATH="$JAVA_HOME/bin:$PATH"

# Verify Java
JAVA_VERSION=$(java -version 2>&1 | head -1)
log "✓ Java verified: $JAVA_VERSION"

# Use Maven from environment or project directory
if [ -d "$PWD/maven" ]; then
    MAVEN_HOME="$PWD/maven"
    export PATH="$MAVEN_HOME/bin:$PATH"
    log "✓ Using project Maven: $MAVEN_HOME"
elif command -v mvn >/dev/null 2>&1; then
    log "✓ Using system Maven: $(which mvn)"
else
    log "ERROR: Maven not found"
    log "Please ensure Maven is available or run the full build script first"
    exit 1
fi

# Quick Maven build
log "Starting Maven build..."
mvn clean compile -q
log "✓ Maven compilation completed"

log "Starting Spring Boot JAR packaging..."
mvn package -DskipTests -q
log "✓ Spring Boot JAR packaging completed"

# Verify JAR was created
JAR_FILE="target/twitch-chat-reader-1.0.jar"
if [ -f "$JAR_FILE" ]; then
    JAR_SIZE=$(stat -c%s "$JAR_FILE" 2>/dev/null || echo "unknown")
    log "✓ JAR file created: $JAR_FILE (${JAR_SIZE} bytes)"
else
    log "ERROR: JAR file not found at $JAR_FILE"
    exit 1
fi

log "=== Fast Build Complete ==="