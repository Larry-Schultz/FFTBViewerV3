# Environment Profile Configuration

This application supports multiple environment profiles to control track play database updates and other settings.

## Available Profiles

### 1. Default (Development Mode)
- **File**: `application.properties`
- **Track Play Updates**: Disabled (`app.track-play.enabled=false`)
- **Log Mode**: Log-only (`app.track-play.log-only=true`)
- **Usage**: Local development and testing

### 2. Development Profile
- **File**: `application-dev.properties`
- **Track Play Updates**: Disabled (`app.track-play.enabled=false`)
- **Log Mode**: Log-only (`app.track-play.log-only=true`)
- **Features**: Enhanced debugging, verbose logging
- **Usage**: Development with detailed logging

### 3. Production Profile
- **File**: `application-prod.properties`
- **Track Play Updates**: Enabled (`app.track-play.enabled=true`)
- **Log Mode**: Full database updates (`app.track-play.log-only=false`)
- **Features**: Optimized performance, minimal logging
- **Usage**: Production deployment

### 4. Legacy Production Profile
- **File**: `application-production.properties`
- **Track Play Updates**: Enabled (`app.track-play.enabled=true`)
- **Log Mode**: Full database updates (`app.track-play.log-only=false`)
- **Features**: Replit-specific optimizations
- **Usage**: Replit production deployment

## How to Use Profiles

### Setting Active Profile

#### Option 1: Environment Variable (Recommended)
```bash
export SPRING_PROFILES_ACTIVE=prod
./run
```

#### Option 2: Maven Command (Development)
```bash
mvn spring-boot:run -Dspring-boot.run.arguments='--server.port=5000 --spring.profiles.active=prod'
```

#### Option 3: Workflow Command (Replit)
```bash
SPRING_PROFILES_ACTIVE=prod mvn spring-boot:run -Dspring-boot.run.arguments=--server.port=5000
```

#### Option 4: JAR Command (Direct)
```bash
java -jar target/twitch-chat-reader-1.0.0.jar --spring.profiles.active=prod
```

### Current Implementation Notes

**The run script has been updated to automatically detect the SPRING_PROFILES_ACTIVE environment variable:**
- If set, it uses the specified profile
- If not set, it falls back to the default profile

**The Maven workflow command currently does NOT specify a profile, so it uses the default profile.**

### Testing Configuration

You can test the current configuration using:
```bash
curl -s http://localhost:5000/api/config/track-play | python3 -m json.tool
```

Expected responses:
- **Default**: `{"enabled": false, "logOnly": true, "shouldUpdateDatabase": false}`
- **Production**: `{"enabled": true, "logOnly": false, "shouldUpdateDatabase": true}`

### Profile Behavior

#### Development Mode (Default)
```
Track play detected: "Song Title"
LOG-ONLY MODE: Would track play for 'Song Title' (180s)
```

#### Production Mode
```
Track play detected: "Song Title"
Tracked play for 'Song Title' (180s) - occurrence now: 15
```

## Configuration Properties

### Track Play Settings
- `app.track-play.enabled`: Enable/disable track play detection
- `app.track-play.log-only`: If true, only log plays without database updates

### Debug Settings
- `app.debug.enabled`: Enable debug features
- `app.debug.log-all-events`: Log all event detections

## Environment-Specific Features

### Development
- SQL query logging enabled
- Verbose debug logging
- All event logging
- Hibernate SQL tracing

### Production
- Optimized connection pooling
- Minimal logging
- Performance tuning
- Compressed responses

## Quick Reference

| Profile | Database Updates | Log Output | Use Case |
|---------|------------------|------------|----------|
| default | ❌ | Log-only | Local development |
| dev | ❌ | Log-only + Debug | Development with debugging |
| prod | ✅ | Full updates | Production deployment |
| production | ✅ | Full updates | Replit production |

## Testing Configuration

### Test Development Mode
```bash
# No profile specified (uses default)
./run
# Watch logs for "LOG-ONLY MODE" messages
```

### Test Production Mode
```bash
export SPRING_PROFILES_ACTIVE=prod
./run
# Watch logs for "Tracked play for..." messages
```

## Best Practices

1. **Never run production profile in development** - It will update the live database
2. **Always use development profile for testing** - Safe to experiment
3. **Set production profile via environment variables** - More secure
4. **Check active profile in logs** - Verify correct configuration on startup
5. **Monitor database updates** - Ensure production mode is working correctly

---

**Last Updated**: July 17, 2025
**Current Status**: Multi-profile configuration active with track play control