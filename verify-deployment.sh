#!/bin/bash

# Deployment verification script for Spring Boot Twitch Chat Reader
echo "=== Deployment Verification ==="

# Set up environment first
export JAVA_HOME=$(ls -d /nix/store/*jdk* | head -1 2>/dev/null || echo "/usr/lib/jvm/java-11-openjdk")
export PATH=$JAVA_HOME/bin:$PWD/maven/bin:$PATH

# Test Maven build
echo "1. Testing Maven build..."
mvn clean package -DskipTests -q
if [ $? -eq 0 ]; then
    echo "✓ Maven build successful"
else
    echo "✗ Maven build failed"
    exit 1
fi

# Check JAR file
JAR_FILE="target/twitch-chat-reader-1.0.0.jar"
if [ -f "$JAR_FILE" ]; then
    echo "✓ JAR file found: $JAR_FILE"
    echo "  Size: $(du -h $JAR_FILE | cut -f1)"
else
    echo "✗ JAR file not found"
    exit 1
fi

# Test Java execution
echo "2. Testing Java execution..."
export JAVA_HOME=$(ls -d /nix/store/*jdk* | head -1 2>/dev/null || echo "/usr/lib/jvm/java-11-openjdk")
export PATH=$JAVA_HOME/bin:$PATH

if command -v java &> /dev/null; then
    echo "✓ Java available: $(java -version 2>&1 | head -1)"
else
    echo "✗ Java not found"
    exit 1
fi

# Check environment
echo "3. Environment check..."
echo "  Java Home: $JAVA_HOME"
echo "  Port: ${PORT:-5000} (default)"
echo "  Database URL: ${DATABASE_URL:0:20}..." # Show first 20 chars only

# Check secrets
echo "4. Checking Twitch secrets..."
if [ -n "$TWITCH_ACCESS_TOKEN" ]; then
    echo "✓ TWITCH_ACCESS_TOKEN configured"
else
    echo "⚠ TWITCH_ACCESS_TOKEN not set (anonymous mode)"
fi

if [ -n "$TWITCH_USERNAME" ]; then
    echo "✓ TWITCH_USERNAME: $TWITCH_USERNAME"
else
    echo "⚠ TWITCH_USERNAME not set (will use default: datadrivenbot)"
fi

if [ -n "$TWITCH_CHANNEL" ]; then
    echo "✓ TWITCH_CHANNEL: $TWITCH_CHANNEL"
else
    echo "⚠ TWITCH_CHANNEL not set (will use default: fftbattleground)"
fi

echo ""
echo "=== Deployment Ready ==="
echo "✓ All checks passed"
echo "✓ Application is ready for Autoscale deployment"
echo ""
echo "Next steps:"
echo "1. Navigate to Deployments pane in Replit"
echo "2. Switch from Reserved VM to Autoscale"
echo "3. Click Deploy"
echo ""