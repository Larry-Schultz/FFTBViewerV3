# Autoscale Deployment Guide for Spring Boot Twitch Chat Reader

## Overview

This guide provides instructions for deploying the Spring Boot Twitch Chat Reader application using Replit's **Autoscale** deployment type, which is the recommended approach for web applications.

## Why Autoscale?

- **Automatic scaling** based on traffic demand
- **Cost-effective** pay-per-use pricing model
- **Better suited for web applications** than Reserved VM
- **Built-in load balancing** and traffic management
- **Faster deployment times** and easier configuration

## Pre-Deployment Setup

### 1. Configure Secrets

In the Replit Secrets tab, add the following environment variables:

```
TWITCH_ACCESS_TOKEN=your_twitch_oauth_token
TWITCH_USERNAME=your_bot_username (optional, defaults to 'datadrivenbot')
TWITCH_CHANNEL=fftbattleground (optional, already set as default)
```

### 2. Verify Database Connection

Ensure the PostgreSQL database is properly configured and accessible via the `DATABASE_URL` environment variable.

### 3. Test Application Locally

Run the application locally to verify it works:
```bash
./run
```

## Deployment Steps

### 1. Switch Deployment Type

1. Navigate to the **Deployments** pane in Replit
2. Go to the **Configuration** tab
3. Change deployment type from "Reserved VM (gce)" to **"Autoscale"**
4. Save the configuration

### 2. Configure Run Command

The `run` script is already optimized for Autoscale deployment with:

- **Dynamic port binding**: Uses `${PORT}` environment variable for Autoscale
- **Optimized JVM settings**: Memory limits and garbage collection tuning
- **Production profile**: Automatically activated for deployment
- **Fast startup**: Skips tests during build process

### 3. Deploy

1. Click the **Deploy** button
2. The application will:
   - Build using Maven with optimized settings
   - Start on the dynamically assigned port
   - Activate production configuration
   - Connect to Twitch chat and database

### 4. Verify Deployment

After deployment:

1. **Web Interface**: Access the deployed URL to see the chat interface
2. **Health Check**: Visit `/actuator/health` for application status
3. **WebSocket**: Real-time chat messages should appear automatically
4. **Database**: Playlist data should load and sync from FFT Battleground

## Configuration Details

### Environment Variables

- `PORT`: Automatically set by Autoscale (dynamic port assignment)
- `SPRING_PROFILES_ACTIVE`: Set to "production" for optimized settings
- `DATABASE_URL`: PostgreSQL connection (automatically available)
- `TWITCH_*`: Your Twitch API credentials (from Secrets)

### JVM Optimization

The application runs with optimized settings:

```bash
-Xmx512m                     # Maximum heap size
-Xms256m                     # Initial heap size  
-XX:+UseG1GC                 # G1 garbage collector
-XX:MaxGCPauseMillis=200     # GC pause time limit
```

### Production Configuration

The `application-production.properties` includes:

- **Server compression**: Reduces bandwidth usage
- **Database connection pooling**: Optimized for concurrent users
- **Reduced logging**: Better performance in production
- **Health monitoring**: Actuator endpoints for deployment health checks

## Troubleshooting

### Common Issues

1. **Build Failures**: Check Maven output for missing dependencies
2. **Port Binding**: Ensure the application uses `${PORT}` variable
3. **Database Connection**: Verify `DATABASE_URL` is accessible
4. **Twitch Authentication**: Check secrets are properly configured

### Debug Commands

```bash
# Test local build
mvn clean package -DskipTests

# Check JAR file
ls -la target/twitch-chat-reader-1.0.0.jar

# Test run script
./run
```

### Health Monitoring

- **Application Health**: `/actuator/health`
- **Database Status**: Included in health endpoint
- **Application Logs**: Available in deployment console
- **WebSocket Status**: Check browser console for connection errors

## Performance Considerations

### Scaling

- **Automatic scaling**: Handles traffic spikes automatically
- **Resource allocation**: Optimized for typical web application usage
- **Database pooling**: Configured for concurrent connections

### Monitoring

- **Real-time metrics**: Available through Replit dashboard
- **Resource usage**: Memory and CPU tracking
- **Response times**: Built-in performance monitoring

## Security

- **Environment variables**: Secrets properly isolated
- **Database access**: Secured through Replit infrastructure
- **HTTPS**: Automatically provided by Autoscale
- **OAuth tokens**: Securely stored in Replit Secrets

## Cost Optimization

- **Pay-per-use**: Only charged when application is actively serving requests
- **Automatic scaling down**: Reduces costs during low traffic
- **Resource efficiency**: Optimized JVM settings reduce memory usage

---

**Ready for deployment!** Your Spring Boot Twitch Chat Reader is now properly configured for Autoscale deployment with optimized performance, security, and cost-effectiveness.