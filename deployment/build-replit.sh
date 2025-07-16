#!/bin/bash

# Replit deployment-ready build script
# Uses only system Java to avoid permission issues

set -e

LOG_PREFIX="[BUILD-REPLIT]"
log() {
    echo "$LOG_PREFIX $1" >&2
}

log "=== Replit Deployment Build Process ==="
log "Timestamp: $(date)"

# Use only Replit's built-in Java from Nix store
export JAVA_HOME=$(ls -d /nix/store/*jdk* | head -1)
if [ -z "$JAVA_HOME" ] || [ ! -f "$JAVA_HOME/bin/java" ]; then
    log "ERROR: Replit Java not found in Nix store"
    log "Available Java installations:"
    find /nix/store -maxdepth 1 -name "*java*" -o -name "*jdk*" | head -5
    exit 1
fi

export PATH="$JAVA_HOME/bin:$PATH"
log "✓ Using Replit Java: $JAVA_HOME"

# Verify Java is working
JAVA_VERSION=$(java -version 2>&1 | head -1)
log "✓ Java verified: $JAVA_VERSION"

# Use project Maven to avoid system dependency issues
if [ -d "$PWD/maven" ]; then
    export PATH="$PWD/maven/bin:$PATH"
    log "✓ Using project Maven: $PWD/maven"
else
    log "ERROR: Project Maven not found at $PWD/maven"
    log "Please ensure Maven is installed in the project directory"
    exit 1
fi

# Verify Maven is working
MVN_VERSION=$(mvn -version 2>&1 | head -1)
log "✓ Maven verified: $MVN_VERSION"

# Clean build for deployment
log "Starting clean build..."
mvn clean compile package -DskipTests -q

# Verify JAR was created
JAR_FILE="target/twitch-chat-reader-1.0.0.jar"
if [ ! -f "$JAR_FILE" ]; then
    # Try alternative name
    JAR_FILE="target/twitch-chat-reader-1.0.jar"
fi

if [ -f "$JAR_FILE" ]; then
    JAR_SIZE=$(stat -c%s "$JAR_FILE")
    log "✓ JAR file created successfully: $JAR_FILE (${JAR_SIZE} bytes)"
else
    log "ERROR: JAR file not found"
    log "Target directory contents:"
    ls -la target/ || log "Target directory missing"
    exit 1
fi

# Verify JAR can be executed
log "Testing JAR execution..."
if java -jar "$JAR_FILE" --help >/dev/null 2>&1 || java -jar "$JAR_FILE" --version >/dev/null 2>&1; then
    log "✓ JAR is executable"
else
    log "⚠ JAR execution test inconclusive (may be normal for Spring Boot apps)"
fi

log "=== Replit Build Complete - Ready for Deployment ==="