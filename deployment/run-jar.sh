#!/bin/bash

# Simple JAR runner for deployment environments
# This script runs the pre-built JAR file directly

set -e

echo "[JAR] === Twitch Chat Reader JAR Start ==="
echo "[JAR] Timestamp: $(date)"

# Set server port
export SERVER_PORT=${PORT:-5000}
echo "[JAR] Starting on port: $SERVER_PORT"

# Find the JAR file
JAR_FILE=$(find target -name "*.jar" -not -name "*sources.jar" 2>/dev/null | head -1)

if [[ -z "$JAR_FILE" || ! -f "$JAR_FILE" ]]; then
    echo "[JAR] ERROR: No JAR file found in target/ directory"
    echo "[JAR] Available files:"
    ls -la target/ 2>/dev/null || echo "No target directory"
    exit 1
fi

echo "[JAR] Found JAR: $JAR_FILE"
echo "[JAR] JAR size: $(ls -lh "$JAR_FILE" | awk '{print $5}')"

# Try different Java executables
JAVA_CMD=""

# First try Nix profile
if [[ -f ~/.nix-profile/bin/java ]]; then
    JAVA_CMD="~/.nix-profile/bin/java"
    echo "[JAR] Found Java in Nix profile: $JAVA_CMD"
elif command -v java >/dev/null 2>&1; then
    JAVA_CMD=$(which java)
    echo "[JAR] Found Java in PATH: $JAVA_CMD"
else
    # Try to find in Nix store
    NIX_JAVA=$(find /nix/store -maxdepth 2 -name "java" -type f -executable 2>/dev/null | head -1)
    if [[ -n "$NIX_JAVA" && -x "$NIX_JAVA" ]]; then
        JAVA_CMD="$NIX_JAVA"
        echo "[JAR] Found Java in Nix store: $JAVA_CMD"
    fi
fi

if [[ -z "$JAVA_CMD" ]]; then
    echo "[JAR] ERROR: No Java executable found"
    echo "[JAR] Searched locations:"
    echo "  - ~/.nix-profile/bin/java"
    echo "  - /nix/store/*/bin/java" 
    echo "  - java (in PATH)"
    exit 1
fi

echo "[JAR] Java version:"
$JAVA_CMD -version 2>&1 | head -3

echo "[JAR] Starting Spring Boot application..."
exec "$JAVA_CMD" -jar "$JAR_FILE" --server.port=$SERVER_PORT