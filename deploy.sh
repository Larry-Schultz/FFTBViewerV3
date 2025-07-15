#!/bin/bash

# Deployment script for Replit Reserved VM
echo "=== Spring Boot Deployment Script ==="

# Set up environment
export JAVA_HOME=$(ls -d /nix/store/*jdk* | head -1)
export PATH=$JAVA_HOME/bin:$PWD/maven/bin:$PATH

# Set server port for deployment
export SERVER_PORT=5000

echo "Building application..."
mvn clean package -DskipTests -q

# Check if build was successful
if [ $? -eq 0 ] && [ -f "target/twitch-chat-reader-1.0.0.jar" ]; then
    echo "Build successful! Starting application..."
    exec java -jar -Dserver.port=$SERVER_PORT target/twitch-chat-reader-1.0.0.jar
else
    echo "Build failed or JAR not found. Please check Maven output."
    exit 1
fi