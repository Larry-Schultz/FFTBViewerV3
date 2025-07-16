#!/bin/bash

# Deployment-ready build script that mirrors the working workflow environment
# This script uses the exact same setup as the current running workflow

set -e

echo "[BUILD-DEPLOY] === Deployment Build Process ==="
echo "[BUILD-DEPLOY] Timestamp: $(date)"

# Mirror the exact workflow environment setup
export JAVA_HOME=$(ls -d /nix/store/*jdk* | head -1)
export PATH=$JAVA_HOME/bin:$PWD/maven/bin:$PATH

echo "[BUILD-DEPLOY] Environment setup complete"
echo "[BUILD-DEPLOY] Java: $JAVA_HOME"
echo "[BUILD-DEPLOY] Maven: $PWD/maven/bin/mvn"

# Build with minimal output for faster deployment
echo "[BUILD-DEPLOY] Building application..."
mvn clean compile spring-boot:repackage -DskipTests -q

# Verify JAR creation
JAR_FILE="target/twitch-chat-reader-1.0.jar"
if [ -f "$JAR_FILE" ]; then
    JAR_SIZE=$(stat -c%s "$JAR_FILE")
    echo "[BUILD-DEPLOY] ✓ Build successful - JAR created (${JAR_SIZE} bytes)"
else
    echo "[BUILD-DEPLOY] ERROR: Build failed - JAR not found"
    exit 1
fi

echo "[BUILD-DEPLOY] === Build Complete ==="