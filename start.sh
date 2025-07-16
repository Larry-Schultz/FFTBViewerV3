#!/bin/bash

# Spring Boot Twitch Chat Reader Startup Script with Enhanced Error Handling
set -e  # Exit on any error

echo "=== Spring Boot Twitch Chat Reader - Enhanced Startup ==="

# Set up Java environment with error handling
echo "Setting up Java environment..."
export JAVA_HOME=$(ls -d /nix/store/*jdk* | head -1 2>/dev/null || echo "/usr/lib/jvm/java-11-openjdk")
export PATH=$JAVA_HOME/bin:$PATH

# Verify Java installation
echo "Verifying Java installation..."
if [ ! -d "$JAVA_HOME" ]; then
    echo "ERROR: JAVA_HOME directory not found: $JAVA_HOME"
    echo "Available Java installations:"
    ls -la /nix/store/*jdk* 2>/dev/null || echo "No Java installations found in /nix/store"
    exit 1
fi

if ! command -v java &> /dev/null; then
    echo "ERROR: Java command not found in PATH"
    echo "JAVA_HOME: $JAVA_HOME"
    echo "PATH: $PATH"
    exit 1
fi

echo "✓ Java found at: $JAVA_HOME"
echo "Java version:"
java -version 2>&1
echo ""

# Set up Maven with error handling
echo "Setting up Maven environment..."
export PATH=$PWD/maven/bin:$PATH

# Verify Maven installation
if [ ! -d "$PWD/maven" ]; then
    echo "ERROR: Maven directory not found at $PWD/maven"
    echo "Creating maven directory and downloading Maven..."
    mkdir -p maven
    # Download and extract Maven if not present
    MAVEN_VERSION=3.9.4
    wget -q "https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"
    tar -xzf "apache-maven-${MAVEN_VERSION}-bin.tar.gz" --strip-components=1 -C maven
    rm "apache-maven-${MAVEN_VERSION}-bin.tar.gz"
fi

if ! command -v mvn &> /dev/null; then
    echo "ERROR: Maven command not found in PATH"
    echo "Maven directory: $PWD/maven"
    echo "PATH: $PATH"
    exit 1
fi

echo "✓ Maven found"
echo "Maven version:"
mvn -version
echo ""

# Set deployment environment variables
export SERVER_PORT=${PORT:-5000}
export SPRING_PROFILES_ACTIVE=production

echo "Deployment Configuration:"
echo "- Java Home: $JAVA_HOME"
echo "- Maven Path: $PWD/maven/bin"
echo "- Server Port: $SERVER_PORT"
echo "- Spring Profile: $SPRING_PROFILES_ACTIVE"
echo ""

# Build the application with enhanced error handling
echo "Building Spring Boot application..."
if ! mvn clean package -DskipTests -Dmaven.test.skip=true -q; then
    echo "ERROR: Maven build failed"
    echo "Attempting to diagnose the issue..."
    echo "Maven version:"
    mvn --version
    echo "Java version:"
    java -version
    echo "Project directory contents:"
    ls -la
    echo "pom.xml exists:"
    [ -f pom.xml ] && echo "✓ Yes" || echo "✗ No"
    exit 1
fi

echo "✓ Maven build completed successfully"

# Check if JAR was built successfully
JAR_FILE="target/twitch-chat-reader-1.0.0.jar"
if [ ! -f "$JAR_FILE" ]; then
    echo "ERROR: JAR file not found at $JAR_FILE"
    echo "Target directory contents:"
    ls -la target/ 2>/dev/null || echo "Target directory does not exist"
    echo "Build may have failed. Check Maven output above."
    exit 1
fi

echo "✓ JAR file built successfully: $JAR_FILE"
echo "Starting Spring Boot application on port $SERVER_PORT..."

# Start the application with optimized JVM settings
exec java \
    -Xmx512m \
    -Xms256m \
    -XX:+UseG1GC \
    -XX:MaxGCPauseMillis=200 \
    -Dserver.port=$SERVER_PORT \
    -Dspring.profiles.active=$SPRING_PROFILES_ACTIVE \
    -Djava.security.egd=file:/dev/./urandom \
    -jar "$JAR_FILE"