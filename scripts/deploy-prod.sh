#!/bin/bash

# Production deployment script with automated testing
# This script ensures only tested code reaches production

set -e

echo "🏭 Starting production deployment..."

# Change to project root
cd "$(dirname "$0")/.."

# Run pre-deployment checks
echo "Running pre-deployment checks..."
./scripts/pre-deploy.sh

# Set production profile
export SPRING_PROFILES_ACTIVE=prod

# Deploy to production
echo "🚀 Deploying to production with profile: $SPRING_PROFILES_ACTIVE"

# Set up Java environment
export JAVA_HOME=/nix/store/023zqb5jvvjhv5l1b0fzdaqxy8c7ilcl-adoptopenjdk-openj9-bin-11.0.11
export PATH=$JAVA_HOME/bin:$PWD/maven/bin:$PATH

# Start application in production mode
echo "Starting application in production mode..."
mvn spring-boot:run -Dspring-boot.run.arguments="--server.port=5000 --spring.profiles.active=prod"