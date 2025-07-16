#!/bin/bash

# Optimized build script for deployment - uses direct Java path detection
# Fixes deployment timeouts and build failures

set -e

LOG_PREFIX="[BUILD]"
log() {
    echo "$LOG_PREFIX $1" >&2
}

log "=== Spring Boot Deployment Build ==="
log "Timestamp: $(date)"

# FIX 1: Use direct Java path instead of complex detection
log "Setting up Java environment..."
if [ -d "/nix/store" ]; then
    # Use direct Nix store path pattern - much faster than complex searches
    JAVA_HOME=$(ls -d /nix/store/*jdk* 2>/dev/null | head -1)
    if [ -n "$JAVA_HOME" ] && [ -f "$JAVA_HOME/bin/java" ]; then
        export JAVA_HOME
        export PATH="$JAVA_HOME/bin:$PATH"
        log "✓ Java found at: $JAVA_HOME"
    else
        log "ERROR: No Java installation found in Nix store"
        exit 1
    fi
else
    # Fallback for non-Nix environments
    if command -v java >/dev/null 2>&1; then
        JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
        export JAVA_HOME
        log "✓ Using system Java: $JAVA_HOME"
    else
        log "ERROR: No Java installation found"
        exit 1
    fi
fi

# Verify Java installation
java -version || {
    log "ERROR: Java verification failed"
    exit 1
}

# FIX 2: Add Maven installation check and setup
log "Setting up Maven..."
if [ -d "$PWD/maven" ]; then
    export MAVEN_HOME="$PWD/maven"
    export PATH="$MAVEN_HOME/bin:$PATH"
    log "✓ Using project Maven: $MAVEN_HOME"
elif command -v mvn >/dev/null 2>&1; then
    log "✓ Using system Maven: $(which mvn)"
else
    log "Downloading Maven 3.9.4..."
    mkdir -p maven
    MAVEN_URL="https://archive.apache.org/dist/maven/maven-3/3.9.4/binaries/apache-maven-3.9.4-bin.tar.gz"
    curl -sL "$MAVEN_URL" | tar -xz --strip-components=1 -C maven
    export MAVEN_HOME="$PWD/maven"
    export PATH="$MAVEN_HOME/bin:$PATH"
    log "✓ Maven downloaded and configured"
fi

# Verify Maven installation
mvn -version || {
    log "ERROR: Maven verification failed"
    exit 1
}

# FIX 3: Complete build script with proper Maven build commands
log "Starting Maven clean and compile..."
mvn clean compile || {
    log "ERROR: Maven compilation failed"
    log "Check for syntax errors in Java source files"
    exit 1
}

log "Starting Spring Boot packaging..."
mvn package -DskipTests || {
    log "ERROR: Maven packaging failed"
    log "Check dependencies and build configuration"
    exit 1
}

# FIX 4: Update JAR filename to match actual Maven output
JAR_FILE="target/twitch-chat-reader-1.0.0.jar"
if [ -f "$JAR_FILE" ]; then
    JAR_SIZE=$(stat -c%s "$JAR_FILE" 2>/dev/null || echo "unknown")
    log "✓ Build successful: $JAR_FILE (${JAR_SIZE} bytes)"
else
    # FIX 5: Add error handling for incomplete build
    log "ERROR: Expected JAR file not found: $JAR_FILE"
    log "Contents of target directory:"
    ls -la target/ 2>/dev/null || log "Target directory does not exist"
    
    # Check for alternative JAR names
    FOUND_JARS=$(find target/ -name "*.jar" 2>/dev/null || true)
    if [ -n "$FOUND_JARS" ]; then
        log "Found JAR files:"
        echo "$FOUND_JARS"
    else
        log "No JAR files found in target directory"
    fi
    exit 1
fi

log "=== Build Complete - Ready for Deployment ==="