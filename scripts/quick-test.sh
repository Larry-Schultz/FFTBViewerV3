#!/bin/bash

# Quick test script for basic validation before deployment

set -e

echo "⚡ Running quick test suite..."

# Set up Java environment
export JAVA_HOME=/nix/store/023zqb5jvvjhv5l1b0fzdaqxy8c7ilcl-adoptopenjdk-openj9-bin-11.0.11
export PATH=$JAVA_HOME/bin:$PWD/maven/bin:$PATH

# 1. Compilation test
echo "🔧 Testing compilation..."
mvn clean compile -q
echo "✅ Compilation successful"

# 2. Unit tests (exclude DatabaseConnectionTest for now)
echo "🧪 Running unit tests..."
mvn test -Dtest=PlaylistSyncServiceTest -q
echo "✅ Unit tests passed"

# 3. XML feed test
echo "🌐 Testing XML feed accessibility..."
if curl -s --max-time 10 'http://www.fftbattleground.com/fftbg/playlist.xml' | head -1 | grep -q 'xml'; then
    echo "✅ XML feed accessible"
else
    echo "❌ XML feed not accessible"
    exit 1
fi

# 4. Build test
echo "📦 Testing build..."
mvn package -DskipTests -q
if [ -f "target/twitch-chat-reader-1.0.0.jar" ]; then
    echo "✅ Build successful"
else
    echo "❌ Build failed"
    exit 1
fi

echo "🎉 All quick tests passed!"