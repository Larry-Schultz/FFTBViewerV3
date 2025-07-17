#!/bin/bash

# Pre-deployment script that runs tests and builds application
# This script should be run before every production deployment

set -e

echo "🚀 Starting pre-deployment checks..."

# Change to project root
cd "$(dirname "$0")/.."

# Run comprehensive test suite
echo "Running test suite..."
./scripts/run-tests.sh

# If tests pass, build the application
if [ $? -eq 0 ]; then
    echo "✅ Tests passed. Building application..."
    
    # Set up Java environment
    export JAVA_HOME=/nix/store/023zqb5jvvjhv5l1b0fzdaqxy8c7ilcl-adoptopenjdk-openj9-bin-11.0.11
    export PATH=$JAVA_HOME/bin:$PWD/maven/bin:$PATH
    
    # Clean build
    mvn clean package -DskipTests -q
    
    # Verify JAR was created
    if [ -f "target/twitch-chat-reader-1.0.0.jar" ]; then
        echo "✅ Application built successfully"
        echo "📦 JAR file: target/twitch-chat-reader-1.0.0.jar"
        echo "🎯 Ready for production deployment!"
    else
        echo "❌ Build failed - JAR file not found"
        exit 1
    fi
else
    echo "❌ Tests failed. Deployment cancelled."
    exit 1
fi