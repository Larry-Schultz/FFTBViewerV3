#!/bin/bash

# Universal startup script that works from any location and handles all deployment scenarios
# This script can be called as start.sh, run, or from any directory

set -e  # Exit on any error

# Enhanced logging for deployment debugging
LOG_PREFIX="[DEPLOYMENT]"
echo "$LOG_PREFIX === Universal Spring Boot Startup ==="
echo "$LOG_PREFIX Timestamp: $(date)"
echo "$LOG_PREFIX Process ID: $$"
echo "$LOG_PREFIX User: $(whoami)"
echo "$LOG_PREFIX Environment variables:"
echo "$LOG_PREFIX   PATH: $PATH"
echo "$LOG_PREFIX   HOME: $HOME"
echo "$LOG_PREFIX   PWD: $PWD"
echo "$LOG_PREFIX   PORT: ${PORT:-not set}"
echo "$LOG_PREFIX   JAVA_HOME: ${JAVA_HOME:-not set}"

# Detect how we were called and from where
SCRIPT_NAME=$(basename "$0")
SCRIPT_DIR=$(dirname "$0")
CURRENT_DIR=$(pwd)

echo "$LOG_PREFIX Script execution details:"
echo "$LOG_PREFIX   Script name: $SCRIPT_NAME"
echo "$LOG_PREFIX   Called from: $CURRENT_DIR"
echo "$LOG_PREFIX   Script location: $SCRIPT_DIR"
echo "$LOG_PREFIX   Command line args: $*"

# Function to find project directory
find_project_directory() {
    local search_paths=(
        "/home/runner/workspace"
        "$CURRENT_DIR"
        "$SCRIPT_DIR"
        "/workspace"
        "$HOME/workspace"
        "$(dirname "$SCRIPT_DIR")"
    )
    
    echo "$LOG_PREFIX Searching for project directory with pom.xml..."
    for path in "${search_paths[@]}"; do
        echo "$LOG_PREFIX   Checking: $path"
        if [ -f "$path/pom.xml" ]; then
            echo "$LOG_PREFIX   ✓ Found pom.xml at: $path"
            echo "$path"
            return 0
        else
            echo "$LOG_PREFIX   ✗ No pom.xml at: $path"
        fi
    done
    
    echo "$LOG_PREFIX ERROR: Cannot locate project directory with pom.xml" >&2
    echo "$LOG_PREFIX Searched paths:" >&2
    for path in "${search_paths[@]}"; do
        echo "$LOG_PREFIX   - $path" >&2
    done
    return 1
}

# Find and change to project directory
echo "$LOG_PREFIX Starting project directory search..."
PROJECT_DIR=$(find_project_directory)
if [ $? -ne 0 ]; then
    echo "$LOG_PREFIX FATAL: Project directory search failed" >&2
    exit 1
fi

echo "$LOG_PREFIX Project directory found: $PROJECT_DIR"
echo "$LOG_PREFIX Changing to project directory..."
cd "$PROJECT_DIR"
echo "$LOG_PREFIX Current working directory: $(pwd)"
echo "$LOG_PREFIX Project directory contents:"
ls -la | head -10

# Set up Java environment with comprehensive error handling
echo "$LOG_PREFIX Setting up Java environment..."
JAVA_CANDIDATES=(
    "$(ls -d /nix/store/*jdk* 2>/dev/null | head -1)"
    "/usr/lib/jvm/java-11-openjdk"
    "/usr/lib/jvm/default-java"
    "/opt/java/openjdk"
)

echo "$LOG_PREFIX Java installation candidates:"
for java_path in "${JAVA_CANDIDATES[@]}"; do
    echo "$LOG_PREFIX   Checking: $java_path"
    if [ -n "$java_path" ] && [ -d "$java_path" ]; then
        echo "$LOG_PREFIX   ✓ Found Java at: $java_path"
        export JAVA_HOME="$java_path"
        break
    else
        echo "$LOG_PREFIX   ✗ Not found: $java_path"
    fi
done

if [ -z "$JAVA_HOME" ] || [ ! -d "$JAVA_HOME" ]; then
    echo "$LOG_PREFIX ERROR: No Java installation found" >&2
    echo "$LOG_PREFIX Available directories in /nix/store:" >&2
    ls -d /nix/store/*jdk* 2>/dev/null | head -5 >&2 || echo "$LOG_PREFIX No JDK directories found" >&2
    exit 1
fi

echo "$LOG_PREFIX Setting JAVA_HOME to: $JAVA_HOME"
export PATH="$JAVA_HOME/bin:$PATH"
echo "$LOG_PREFIX Updated PATH: $PATH"

# Verify Java
echo "$LOG_PREFIX Verifying Java installation..."
if ! command -v java &> /dev/null; then
    echo "$LOG_PREFIX ERROR: Java command not available after PATH update" >&2
    echo "$LOG_PREFIX Contents of JAVA_HOME/bin:" >&2
    ls -la "$JAVA_HOME/bin/" | head -5 >&2 || echo "$LOG_PREFIX Cannot list JAVA_HOME/bin" >&2
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | head -1)
echo "$LOG_PREFIX ✓ Java verified: $JAVA_VERSION"

# Set up Maven
echo "$LOG_PREFIX Setting up Maven..."
MAVEN_HOME="$PWD/maven"
echo "$LOG_PREFIX Maven home set to: $MAVEN_HOME"
export PATH="$MAVEN_HOME/bin:$PATH"
echo "$LOG_PREFIX Updated PATH with Maven: $PATH"

# Download Maven if not present
if [ ! -d "$MAVEN_HOME" ]; then
    echo "$LOG_PREFIX Maven directory not found, downloading Maven 3.9.4..."
    mkdir -p "$MAVEN_HOME"
    MAVEN_URL="https://archive.apache.org/dist/maven/maven-3/3.9.4/binaries/apache-maven-3.9.4-bin.tar.gz"
    
    echo "$LOG_PREFIX Checking download tools..."
    if command -v wget &> /dev/null; then
        echo "$LOG_PREFIX Using wget to download Maven..."
        wget -q "$MAVEN_URL" -O maven.tar.gz
    elif command -v curl &> /dev/null; then
        echo "$LOG_PREFIX Using curl to download Maven..."
        curl -sL "$MAVEN_URL" -o maven.tar.gz
    else
        echo "$LOG_PREFIX ERROR: Neither wget nor curl available for Maven download" >&2
        exit 1
    fi
    
    echo "$LOG_PREFIX Extracting Maven archive..."
    tar -xzf maven.tar.gz --strip-components=1 -C "$MAVEN_HOME"
    rm maven.tar.gz
    echo "$LOG_PREFIX Maven download and extraction completed"
else
    echo "$LOG_PREFIX Maven directory already exists: $MAVEN_HOME"
fi

# Verify Maven
echo "$LOG_PREFIX Verifying Maven installation..."
if ! command -v mvn &> /dev/null; then
    echo "$LOG_PREFIX ERROR: Maven command not available" >&2
    echo "$LOG_PREFIX Contents of Maven bin directory:" >&2
    ls -la "$MAVEN_HOME/bin/" | head -5 >&2 || echo "$LOG_PREFIX Cannot list Maven bin directory" >&2
    exit 1
fi

MAVEN_VERSION=$(mvn -version | head -1)
echo "$LOG_PREFIX ✓ Maven verified: $MAVEN_VERSION"

# Set deployment variables
export SERVER_PORT="${PORT:-5000}"
export SPRING_PROFILES_ACTIVE="production"

echo "$LOG_PREFIX Application configuration:"
echo "$LOG_PREFIX   - Server Port: $SERVER_PORT"
echo "$LOG_PREFIX   - Spring Profile: $SPRING_PROFILES_ACTIVE"
echo "$LOG_PREFIX   - Project Directory: $PROJECT_DIR"
echo "$LOG_PREFIX   - Java Home: $JAVA_HOME"
echo "$LOG_PREFIX   - Maven Home: $MAVEN_HOME"

# Build the application
echo "$LOG_PREFIX Building application with Maven..."
echo "$LOG_PREFIX Maven command: mvn clean package -DskipTests -Dmaven.test.skip=true"
if ! mvn clean package -DskipTests -Dmaven.test.skip=true -q; then
    echo "$LOG_PREFIX ERROR: Maven build failed" >&2
    echo "$LOG_PREFIX Build diagnostics:" >&2
    echo "$LOG_PREFIX Maven version:" >&2
    mvn --version >&2
    echo "$LOG_PREFIX Java version:" >&2
    java -version >&2
    echo "$LOG_PREFIX Project structure:" >&2
    ls -la >&2
    exit 1
fi
echo "$LOG_PREFIX Maven build completed successfully"

# Verify JAR
JAR_FILE="target/twitch-chat-reader-1.0.0.jar"
echo "$LOG_PREFIX Verifying JAR file: $JAR_FILE"
if [ ! -f "$JAR_FILE" ]; then
    echo "$LOG_PREFIX ERROR: JAR file not found: $JAR_FILE" >&2
    echo "$LOG_PREFIX Target directory contents:" >&2
    ls -la target/ >&2 || echo "$LOG_PREFIX Target directory missing" >&2
    exit 1
fi

JAR_SIZE=$(ls -lh "$JAR_FILE" | awk '{print $5}')
echo "$LOG_PREFIX ✓ JAR built successfully: $JAR_FILE ($JAR_SIZE)"
echo "$LOG_PREFIX Starting Spring Boot application..."

# Start with optimized settings
echo "$LOG_PREFIX Executing Java application with optimized JVM settings..."
exec java \
    -Xmx512m \
    -Xms256m \
    -XX:+UseG1GC \
    -XX:MaxGCPauseMillis=200 \
    -XX:+ExitOnOutOfMemoryError \
    -Dserver.port="$SERVER_PORT" \
    -Dspring.profiles.active="$SPRING_PROFILES_ACTIVE" \
    -Djava.security.egd=file:/dev/./urandom \
    -Dfile.encoding=UTF-8 \
    -jar "$JAR_FILE"