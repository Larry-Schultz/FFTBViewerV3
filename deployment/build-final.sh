#!/bin/bash

# OPTIMIZED BUILD SCRIPT FOR DEPLOYMENT
# Addresses all deployment timeout and build failure issues

set -e

echo "[DEPLOY-BUILD] === Deployment-Ready Build Process ==="
echo "[DEPLOY-BUILD] Timestamp: $(date)"

# FIX 1: Direct Java path detection (no complex searches)
JAVA_HOME=$(ls -d /nix/store/*jdk* | head -1)
if [ -z "$JAVA_HOME" ] || [ ! -f "$JAVA_HOME/bin/java" ]; then
    echo "[DEPLOY-BUILD] ERROR: Java not found in expected location"
    exit 1
fi

export JAVA_HOME
export PATH="$JAVA_HOME/bin:$PATH"
echo "[DEPLOY-BUILD] ✓ Java: $JAVA_HOME"

# FIX 2: Maven setup with error handling
if [ -d "$PWD/maven" ]; then
    export MAVEN_HOME="$PWD/maven"
    export PATH="$MAVEN_HOME/bin:$PATH"
    echo "[DEPLOY-BUILD] ✓ Maven: $MAVEN_HOME"
else
    echo "[DEPLOY-BUILD] ERROR: Maven not found. Run initial setup first."
    exit 1
fi

# Verify environment
java -version 2>&1 | head -1 | cut -d'"' -f2
mvn -version | head -1

# FIX 3: Optimized build process
echo "[DEPLOY-BUILD] Starting optimized build..."

# Only compile if needed (faster than clean)
if [ ! -d "target/classes" ]; then
    echo "[DEPLOY-BUILD] Compiling source..."
    mvn compile -q
else
    echo "[DEPLOY-BUILD] Using existing compiled classes"
fi

# FIX 4: Create executable JAR
echo "[DEPLOY-BUILD] Creating deployment JAR..."
mvn package -DskipTests -q

# FIX 5: Verify JAR creation with correct filename
JAR_FILE="target/twitch-chat-reader-1.0.0.jar"
if [ -f "$JAR_FILE" ]; then
    SIZE=$(stat -c%s "$JAR_FILE")
    echo "[DEPLOY-BUILD] ✓ Deployment JAR ready: $JAR_FILE (${SIZE} bytes)"
else
    echo "[DEPLOY-BUILD] ERROR: JAR creation failed"
    echo "[DEPLOY-BUILD] Target contents:"
    ls -la target/ 2>/dev/null || echo "No target directory"
    exit 1
fi

echo "[DEPLOY-BUILD] === Build Ready for Deployment ==="