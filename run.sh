#!/bin/bash

# Set up Java environment
export JAVA_HOME=$(ls -d /nix/store/*jdk* | head -1)
export PATH=$JAVA_HOME/bin:$PATH

# Set up Maven
export PATH=$PWD/maven/bin:$PATH

# Verify Java installation
echo "Java version:"
java -version
echo ""

echo "Maven version:"
mvn -version
echo ""

# Run the Twitch Chat Reader
echo "Starting Twitch Chat Reader..."
mvn clean compile exec:java -Dexec.mainClass="com.twitchchat.TwitchChatReader"