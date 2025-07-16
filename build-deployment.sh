#!/bin/bash

# Fast deployment build script - mirrors the exact working workflow environment
# Uses the same Java and Maven detection as the running workflow

set -e

echo "[BUILD-DEPLOY] === Fast Deployment Build ==="
echo "[BUILD-DEPLOY] Timestamp: $(date)"

# Use the exact same environment setup as the workflow
export JAVA_HOME=$(ls -d /nix/store/*jdk* | head -1)
export PATH=$JAVA_HOME/bin:$PWD/maven/bin:$PATH

echo "[BUILD-DEPLOY] Java: $JAVA_HOME"
echo "[BUILD-DEPLOY] Maven: $PWD/maven"

# Verify environment
java -version 2>/dev/null || {
    echo "[BUILD-DEPLOY] ERROR: Java not available"
    exit 1
}

# Check Maven installation or download it
if [ ! -d "$PWD/maven" ]; then
    echo "[BUILD-DEPLOY] Downloading Maven..."
    mkdir -p maven
    MAVEN_URL="https://archive.apache.org/dist/maven/maven-3/3.9.4/binaries/apache-maven-3.9.4-bin.tar.gz"
    curl -sL "$MAVEN_URL" | tar -xz --strip-components=1 -C maven
    echo "[BUILD-DEPLOY] ✓ Maven ready"
fi

mvn -version 2>/dev/null || {
    echo "[BUILD-DEPLOY] ERROR: Maven not available"
    exit 1
}

# Clean and fast build
echo "[BUILD-DEPLOY] Building application..."
mvn clean compile spring-boot:repackage -DskipTests -q

# Verify JAR creation
JAR_FILE="target/twitch-chat-reader-1.0.0.jar"
if [ -f "$JAR_FILE" ]; then
    JAR_SIZE=$(stat -c%s "$JAR_FILE")
    echo "[BUILD-DEPLOY] ✓ Build successful - JAR created (${JAR_SIZE} bytes)"
else
    echo "[BUILD-DEPLOY] ERROR: JAR not found"
    ls -la target/ 2>/dev/null || echo "[BUILD-DEPLOY] No target directory"
    exit 1
fi

echo "[BUILD-DEPLOY] === Build Complete ==="