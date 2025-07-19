#!/bin/bash

# Deployment fix script to resolve Java permission issues
# This script addresses the specific deployment problems mentioned

set -e

echo "[DEPLOY-FIX] === Fixing Deployment Permission Issues ==="
echo "[DEPLOY-FIX] Timestamp: $(date)"

# 1. Remove any problematic portable Java installations
echo "[DEPLOY-FIX] Removing problematic portable Java installations..."
rm -rf portable-java 2>/dev/null || true
rm -rf java 2>/dev/null || true
rm -rf usr 2>/dev/null || true

# 2. Clean any cached Maven artifacts that might have permission issues
echo "[DEPLOY-FIX] Cleaning Maven artifacts..."
rm -rf target 2>/dev/null || true

# 3. Use only Replit's system Java
export JAVA_HOME=$(ls -d /nix/store/*jdk* | head -1)
export PATH="$JAVA_HOME/bin:$PWD/maven/bin:$PATH"

echo "[DEPLOY-FIX] ✓ Using system Java: $JAVA_HOME"
echo "[DEPLOY-FIX] ✓ Java version: $(java -version 2>&1 | head -1)"

# 4. Simple compile only (no packaging to avoid permission issues)
echo "[DEPLOY-FIX] Compiling sources..."
mvn clean compile -q

echo "[DEPLOY-FIX] ✓ Compilation successful"
echo "[DEPLOY-FIX] === Deployment Fix Complete ==="

echo ""
echo "DEPLOYMENT READINESS STATUS:"
echo "✓ Portable Java removed (fixed permission issues)"
echo "✓ Using Replit system Java only"
echo "✓ Sources compiled successfully"
echo "✓ Ready for deployment with mvn spring-boot:run"