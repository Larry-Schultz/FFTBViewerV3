# Deployment Guide for Spring Boot Twitch Chat Reader

## Reserved VM Deployment Configuration

The application is now properly configured for Replit's Reserved VM deployment type.

### Key Files for Deployment

1. **`run` script**: Main production entry point
   - Sets up Java and Maven environment
   - Builds the application with `mvn clean package -DskipTests`
   - Starts the Spring Boot application on port 5000
   - Uses production profile (`-Dspring.profiles.active=production`)

2. **`Dockerfile`**: Container configuration for Reserved VM
   - Based on OpenJDK 11 JRE slim image
   - Includes health checks for application monitoring
   - Exposes port 5000
   - Configures production environment variables

3. **`application-production.properties`**: Production-specific configuration
   - Optimized logging levels
   - Database connection pooling settings
   - WebSocket configuration
   - Health check endpoints enabled

### Deployment Steps

1. **Prerequisites:**
   - Ensure all Twitch API secrets are configured in Replit Secrets:
     - `TWITCH_ACCESS_TOKEN`
     - `TWITCH_USERNAME` (optional, defaults to 'datadrivenbot')
     - `TWITCH_CHANNEL` (optional, defaults to 'fftbattleground')

2. **Build and Test:**
   ```bash
   # Test the build process
   ./run
   ```

3. **Deploy:**
   - Use Replit's deployment interface
   - Select "Reserved VM" deployment type
   - The `run` script will be automatically executed
   - Application will be available on port 5000

### Health Monitoring

- Health check endpoint: `/actuator/health`
- Docker health checks are configured with 90-second startup period
- Application logs provide detailed startup information

### Database Connection

- Uses PostgreSQL database with optimized connection pooling
- Automatic schema updates via Hibernate DDL
- Connection pool configured for 10 max connections in production

### Performance Optimizations

- JPA batch operations enabled
- Hibernate query optimizations
- WebSocket message size limits
- Reduced logging in production mode

### Troubleshooting

If deployment fails:

1. Check that all environment variables are set
2. Verify Java 11 compatibility
3. Ensure PostgreSQL database is accessible
4. Review application logs for startup errors
5. Test the `run` script manually

### Port Configuration

- Application runs on port 5000 (required for Replit)
- WebSocket endpoint available at `/ws`
- Health checks available at `/actuator/health`