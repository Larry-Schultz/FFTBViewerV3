# Dockerfile for Spring Boot Twitch Chat Reader - Reserved VM Deployment
FROM openjdk:11-jre-slim

# Install curl for health checks and any required dependencies
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Create app directory and user
WORKDIR /app

# Copy the pre-built JAR file
COPY target/twitch-chat-reader-1.0.0.jar app.jar

# Expose port 5000 (matches our Spring Boot configuration)
EXPOSE 5000

# Health check for the Spring Boot application
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
  CMD curl -f http://localhost:5000/actuator/health || curl -f http://localhost:5000/ || exit 1

# Set environment variables for Spring Boot
ENV SPRING_PROFILES_ACTIVE=production
ENV SERVER_PORT=5000
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# Run the Spring Boot application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar -Dserver.port=$SERVER_PORT /app/app.jar"]