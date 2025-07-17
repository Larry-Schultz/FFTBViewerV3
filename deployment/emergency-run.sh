#!/bin/bash

# Emergency deployment script - finds Java and runs JAR directly
# This bypasses all complex environment setup

set -e

echo "[EMERGENCY] === Emergency Twitch Chat Reader Start ==="
echo "[EMERGENCY] Timestamp: $(date)"

# Set server port
export SERVER_PORT=${PORT:-5000}
echo "[EMERGENCY] Target port: $SERVER_PORT"

# Find JAR file
JAR_FILE=$(find target -name "*.jar" -not -name "*sources.jar" 2>/dev/null | head -1)

if [ -z "$JAR_FILE" ] || [ ! -f "$JAR_FILE" ]; then
    echo "[EMERGENCY] ERROR: No JAR file found"
    ls -la target/ 2>/dev/null || echo "No target directory"
    exit 1
fi

echo "[EMERGENCY] Found JAR: $JAR_FILE"
echo "[EMERGENCY] JAR size: $(ls -lh "$JAR_FILE" | awk '{print $5}')"

# Find any working Java executable
echo "[EMERGENCY] Searching for Java..."

# Multiple detection strategies for deployment environment
WORKING_JAVA=""

# Strategy 1: Use JAVA_HOME if set
if [ -n "$JAVA_HOME" ] && [ -x "$JAVA_HOME/bin/java" ]; then
    echo "[EMERGENCY] Testing JAVA_HOME: $JAVA_HOME/bin/java"
    if "$JAVA_HOME/bin/java" -version >/dev/null 2>&1; then
        WORKING_JAVA="$JAVA_HOME/bin/java"
        echo "[EMERGENCY] ✓ Working Java found via JAVA_HOME: $WORKING_JAVA"
    fi
fi

# Strategy 2: Check PATH
if [ -z "$WORKING_JAVA" ]; then
    if command -v java >/dev/null 2>&1; then
        JAVA_PATH=$(command -v java)
        echo "[EMERGENCY] Testing PATH Java: $JAVA_PATH"
        if "$JAVA_PATH" -version >/dev/null 2>&1; then
            WORKING_JAVA="$JAVA_PATH"
            echo "[EMERGENCY] ✓ Working Java found in PATH: $WORKING_JAVA"
        fi
    fi
fi

# Strategy 3: Search Nix store (limited search to avoid timeouts)
if [ -z "$WORKING_JAVA" ]; then
    echo "[EMERGENCY] Searching Nix store..."
    NIX_JAVA=$(find /nix/store -maxdepth 2 -name "java" -type f -executable 2>/dev/null | head -1)
    if [ -n "$NIX_JAVA" ] && [ -x "$NIX_JAVA" ]; then
        echo "[EMERGENCY] Testing Nix Java: $NIX_JAVA"
        if "$NIX_JAVA" -version >/dev/null 2>&1; then
            WORKING_JAVA="$NIX_JAVA"
            echo "[EMERGENCY] ✓ Working Java found in Nix: $WORKING_JAVA"
        fi
    fi
fi

if [ -z "$WORKING_JAVA" ]; then
    echo "[EMERGENCY] FATAL: No working Java found"
    echo "[EMERGENCY] Checked locations:"
    printf '  %s\n' "${JAVA_CANDIDATES[@]}"
    exit 1
fi

echo "[EMERGENCY] Java version:"
"$WORKING_JAVA" -version 2>&1 | head -3

echo "[EMERGENCY] Starting Spring Boot application..."
echo "[EMERGENCY] Command: $WORKING_JAVA -jar $JAR_FILE --server.port=$SERVER_PORT"

exec "$WORKING_JAVA" -jar "$JAR_FILE" --server.port=$SERVER_PORT