#!/bin/bash

# Hybrid build script - tries environment first, falls back to minimal setup
# Optimized for deployment speed

set -e

LOG_PREFIX="[BUILD]"
log() {
    echo "$LOG_PREFIX $1" >&2
}

log "=== Hybrid Spring Boot Build ==="
log "Timestamp: $(date)"

# Strategy 1: Try to use existing Nix Java quickly
if [ -d "/nix/store" ]; then
    EXISTING_JAVA=$(ls /nix/store/*jdk*/bin/java 2>/dev/null | head -1)
    if [ -n "$EXISTING_JAVA" ]; then
        JAVA_HOME=$(dirname $(dirname "$EXISTING_JAVA"))
        export JAVA_HOME
        export PATH="$JAVA_HOME/bin:$PWD/maven/bin:$PATH"
        log "✓ Using existing Java: $JAVA_HOME"
    fi
fi

# Strategy 2: If no Java found, use a minimal portable version
if ! command -v java >/dev/null 2>&1; then
    log "No Java found, using minimal setup..."
    
    # Try to use any available Java in the system
    for java_path in /usr/bin/java /usr/local/bin/java; do
        if [ -f "$java_path" ]; then
            export PATH="$(dirname $java_path):$PWD/maven/bin:$PATH"
            log "✓ Using system Java: $java_path"
            break
        fi
    done
    
    # If still no Java, quick minimal download
    if ! command -v java >/dev/null 2>&1; then
        log "Downloading minimal Java runtime..."
        mkdir -p portable-jre
        
        # Use a smaller JRE instead of full JDK
        JRE_URL="https://download.bell-sw.com/java/11.0.19+7/bellsoft-jre11.0.19+7-linux-amd64.tar.gz"
        curl -sL "$JRE_URL" | tar -xz --strip-components=1 -C portable-jre
        
        export JAVA_HOME="$PWD/portable-jre"
        export PATH="$JAVA_HOME/bin:$PWD/maven/bin:$PATH"
        log "✓ Portable JRE ready"
    fi
fi

# Quick build
log "Building..."
mvn package -DskipTests -q

# Verify
if [ -f "target/twitch-chat-reader-1.0.jar" ]; then
    log "✓ Build successful"
else
    log "ERROR: Build failed"
    exit 1
fi

log "=== Complete ==="