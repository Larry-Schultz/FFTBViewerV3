# Multi-stage build for Spring Boot Twitch Chat Reader
FROM openjdk:11-jre-slim AS runtime

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy the JAR file (will be built by Replit)
COPY target/twitch-chat-reader-1.0.0.jar app.jar

# Expose port 5000
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:5000/actuator/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "-Dserver.port=5000", "/app/app.jar"]