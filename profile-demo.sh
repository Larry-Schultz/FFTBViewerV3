#!/bin/bash

# Profile Demo Script
# Shows how different profiles affect the application configuration

echo "=== Profile Configuration Demo ==="
echo

# Function to test a profile
test_profile() {
    local profile=$1
    local description=$2
    
    echo "Testing Profile: $profile ($description)"
    echo "Command: curl -s http://localhost:5000/api/config/track-play"
    
    # Check if server is running
    if curl -s http://localhost:5000/api/config/track-play > /dev/null 2>&1; then
        echo "Response:"
        curl -s http://localhost:5000/api/config/track-play | python3 -m json.tool
    else
        echo "Server not running or not responding"
    fi
    
    echo
    echo "---"
    echo
}

# Test current profile
echo "Current Application Status:"
test_profile "current" "Currently running"

echo "To switch profiles, use one of these methods:"
echo
echo "1. Maven Command:"
echo "   mvn spring-boot:run -Dspring-boot.run.arguments='--server.port=5000 --spring.profiles.active=prod'"
echo
echo "2. Environment Variable:"
echo "   export SPRING_PROFILES_ACTIVE=prod"
echo "   ./run"
echo
echo "3. Workflow Command:"
echo "   SPRING_PROFILES_ACTIVE=prod mvn spring-boot:run -Dspring-boot.run.arguments=--server.port=5000"
echo
echo "4. JAR Command:"
echo "   java -jar target/twitch-chat-reader-1.0.0.jar --spring.profiles.active=prod"
echo

echo "Expected Results:"
echo "- default profile: enabled=false, logOnly=true, shouldUpdateDatabase=false"
echo "- prod profile:    enabled=true,  logOnly=false, shouldUpdateDatabase=true"
echo "- dev profile:     enabled=false, logOnly=true, shouldUpdateDatabase=false"