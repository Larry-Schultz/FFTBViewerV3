# Deployment Guide

This project uses a simplified deployment setup with only essential scripts.

## Deployment Scripts

### Production Deployment

**For Replit Deployments:**
- `run` - Main deployment script that works in all environments
- `bin/run` - PATH-compatible version for deployment systems
- `start.sh` - Alternative startup script with enhanced error handling

### Key Features

All deployment scripts include:
- ✅ **Automatic Java detection** with multiple fallback paths
- ✅ **Maven auto-download** if not present
- ✅ **Comprehensive error handling** with detailed diagnostics
- ✅ **Environment variable configuration** for PORT and profiles
- ✅ **JVM optimization** for 512MB memory limit
- ✅ **Project directory detection** from any location

### Usage

**For Replit Deployments:**
1. The deployment system will automatically use `run` or `bin/run`
2. No manual configuration needed - scripts handle all environment setup
3. Supports both Autoscale and Reserved VM deployment types

**For manual execution:**
```bash
# Option 1: Use the main run script
./run

# Option 2: Use the enhanced start script
./start.sh
```

### Environment Variables

The scripts automatically configure:
- `SERVER_PORT` - Uses `PORT` environment variable or defaults to 5000
- `SPRING_PROFILES_ACTIVE` - Set to "production" for deployments
- `JAVA_HOME` - Auto-detected from multiple locations
- `MAVEN_HOME` - Set to `./maven` with auto-download

### Troubleshooting

All scripts include comprehensive logging with `[DEPLOYMENT]` prefix for easy debugging. They will:
1. Show detailed environment information
2. Report Java and Maven versions
3. Provide build diagnostics on failure
4. Verify JAR file creation and size

### Files Removed

The following redundant scripts were removed to simplify maintenance:
- `deploy.sh`, `run.sh`, `start-autoscale.sh`, `start-deployment.sh`
- `start-universal.sh`, `run-wrapper.sh`, `deployment-runner.sh`
- `deployment-debug.sh`, `verify-deployment.sh`, `verify-deployment-fixes.sh`

All functionality has been consolidated into the remaining essential scripts.