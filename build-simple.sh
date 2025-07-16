#!/bin/bash

# Simple build script that uses the same environment as the workflow
# This avoids the Java detection timeout issue

set -e

echo "[BUILD-SIMPLE] === Simple Spring Boot Build Process ==="
echo "[BUILD-SIMPLE] Timestamp: $(date)"

# Use the same Java/Maven setup as the workflow
export JAVA_HOME=$(ls -d /nix/store/*jdk* | head -1)
export PATH=$JAVA_HOME/bin:$PWD/maven/bin:$PATH

echo "[BUILD-SIMPLE] Using JAVA_HOME: $JAVA_HOME"
echo "[BUILD-SIMPLE] Using Maven: $PWD/maven/bin/mvn"

# Quick build without verbose output
echo "[BUILD-SIMPLE] Starting Maven clean compile..."
mvn clean compile -q

echo "[BUILD-SIMPLE] Starting Maven package..."
mvn package -DskipTests -q

# Check if JAR was created
JAR_FILE="target/twitch-chat-reader-1.0.jar"
if [ -f "$JAR_FILE" ]; then
    echo "[BUILD-SIMPLE] ✓ JAR file created successfully: $JAR_FILE"
else
    echo "[BUILD-SIMPLE] ERROR: JAR file not found"
    exit 1
fi

echo "[BUILD-SIMPLE] === Build Complete ==="