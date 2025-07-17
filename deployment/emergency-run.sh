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

if [[ -z "$JAR_FILE" || ! -f "$JAR_FILE" ]]; then
    echo "[EMERGENCY] ERROR: No JAR file found"
    ls -la target/ 2>/dev/null || echo "No target directory"
    exit 1
fi

echo "[EMERGENCY] Found JAR: $JAR_FILE"
echo "[EMERGENCY] JAR size: $(ls -lh "$JAR_FILE" | awk '{print $5}')"

# Find any working Java executable
echo "[EMERGENCY] Searching for Java..."

# Direct search in Nix store
JAVA_CANDIDATES=(
    $(find /nix/store -name "java" -type f -executable 2>/dev/null)
    $(which java 2>/dev/null || true)
)

WORKING_JAVA=""
for java_candidate in "${JAVA_CANDIDATES[@]}"; do
    if [[ -n "$java_candidate" && -x "$java_candidate" ]]; then
        echo "[EMERGENCY] Testing Java: $java_candidate"
        if "$java_candidate" -version >/dev/null 2>&1; then
            WORKING_JAVA="$java_candidate"
            echo "[EMERGENCY] ✓ Working Java found: $WORKING_JAVA"
            break
        else
            echo "[EMERGENCY] ✗ Java test failed: $java_candidate"
        fi
    fi
done

if [[ -z "$WORKING_JAVA" ]]; then
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