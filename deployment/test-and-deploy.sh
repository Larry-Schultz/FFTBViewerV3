#!/bin/bash

# Complete test and deployment script
# This script tests everything before deploying to production

set -e

echo "🚀 Starting complete test and deployment process..."

# Change to project root
cd "$(dirname "$0")/.."

# Set up Java environment
export JAVA_HOME=/nix/store/023zqb5jvvjhv5l1b0fzdaqxy8c7ilcl-adoptopenjdk-openj9-bin-11.0.11
export PATH=$JAVA_HOME/bin:$PWD/maven/bin:$PATH

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Phase 1: Running comprehensive tests${NC}"

# 1. Compilation
echo "🔧 Testing compilation..."
if mvn clean compile -q; then
    echo -e "${GREEN}✅ Compilation successful${NC}"
else
    echo -e "${RED}❌ Compilation failed${NC}"
    exit 1
fi

# 2. Unit tests
echo "🧪 Running unit tests..."
if mvn test -Dtest=PlaylistSyncServiceTest -q; then
    echo -e "${GREEN}✅ Unit tests passed${NC}"
else
    echo -e "${RED}❌ Unit tests failed${NC}"
    exit 1
fi

# 3. XML feed accessibility
echo "🌐 Testing XML feed accessibility..."
if curl -s --max-time 10 'http://www.fftbattleground.com/fftbg/playlist.xml' | head -1 | grep -q 'xml'; then
    echo -e "${GREEN}✅ XML feed accessible${NC}"
else
    echo -e "${RED}❌ XML feed not accessible${NC}"
    exit 1
fi

# 4. Build
echo "📦 Building application..."
if mvn package -DskipTests -q; then
    echo -e "${GREEN}✅ Build successful${NC}"
else
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

# 5. JAR verification
if [ -f "target/twitch-chat-reader-1.0.0.jar" ]; then
    echo -e "${GREEN}✅ JAR file created successfully${NC}"
else
    echo -e "${RED}❌ JAR file not found${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 All tests passed! Ready for deployment.${NC}"

# If we get here, all tests passed
echo -e "${YELLOW}Phase 2: Deploying to production${NC}"

# Set production profile
export SPRING_PROFILES_ACTIVE=prod

# Deploy to production
echo "🚀 Starting production deployment..."
mvn spring-boot:run -Dspring-boot.run.arguments="--server.port=5000 --spring.profiles.active=prod"