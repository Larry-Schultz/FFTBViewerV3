#!/bin/bash

# Direct start script for deployment environments
# Bypasses permission issues by using direct commands

set -e

echo "[START] === Twitch Chat Reader Direct Start ==="
echo "[START] Timestamp: $(date)"

# Set up Java environment directly
export JAVA_HOME=$(ls -d /nix/store/*jdk* | head -1)
export PATH="$JAVA_HOME/bin:$PWD/maven/bin:$PATH"

echo "[START] Java: $JAVA_HOME"
echo "[START] Maven: $PWD/maven/bin/mvn"

# Set server port
export SERVER_PORT=${PORT:-5000}

echo "[START] Starting on port: $SERVER_PORT"

# Run Spring Boot application directly
exec mvn spring-boot:run -Dspring-boot.run.arguments=--server.port=$SERVER_PORT