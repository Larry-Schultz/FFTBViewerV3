# Deployment Guide

This project uses separate build and run scripts for optimal deployment.

## Scripts Overview

### Build Script
- `build.sh` - Handles compilation, dependency management, and JAR creation

### Runtime Scripts  
- `run` - Main runtime script for production deployment
- `bin/run` - PATH-compatible version for deployment systems  
- `start.sh` - Alternative runtime script with enhanced error handling

## Deployment Architecture

**Build Phase (build.sh):**
- ✅ **Java environment setup** with automatic JDK detection/download
- ✅ **Maven installation** with auto-download if needed
- ✅ **Project compilation** and JAR packaging
- ✅ **Build verification** with comprehensive error reporting

**Runtime Phase (run/start.sh):**
- ✅ **Minimal Java runtime** detection for running JAR
- ✅ **Environment configuration** for PORT and Spring profiles
- ✅ **JAR execution** with optimized JVM settings
- ✅ **Error handling** for missing build artifacts

### Usage

**For Replit Deployments:**
1. **Build Phase**: Replit will automatically execute `build.sh`
2. **Runtime Phase**: Replit will then execute `run` or `bin/run` 
3. No manual configuration needed - scripts handle all environment setup
4. Supports both Autoscale and Reserved VM deployment types

**For manual execution:**
```bash
# Step 1: Build the application
./build.sh

# Step 2: Run the application  
./run
# OR alternatively:
./start.sh
```

### Environment Variables

**Build Phase:**
- `JAVA_HOME` - Auto-detected/downloaded for compilation
- `MAVEN_HOME` - Set to `./maven` with auto-download

**Runtime Phase:**
- `SERVER_PORT` - Uses `PORT` environment variable or defaults to 5000
- `SPRING_PROFILES_ACTIVE` - Set to "production" for deployments
- `JAVA_HOME` - Minimal detection for JAR execution

### Troubleshooting

**Build Script (`build.sh`):**
- Uses `[BUILD]` prefix for logging
- Shows Java/Maven setup and versions
- Provides detailed build diagnostics on failure
- Verifies JAR file creation and size

**Runtime Scripts (`run`/`start.sh`):**
- Use `[DEPLOYMENT]` prefix for logging  
- Show runtime environment information
- Verify JAR file exists before attempting to run
- Provide clear error messages if build artifacts missing

### Architecture Benefits

**Separation of Concerns:**
- Build complexity isolated from runtime
- Runtime scripts are lightweight and fast
- Build failures don't affect runtime environment
- Easier debugging and maintenance

**Replit Integration:**
- Optimized for Replit's build/run separation
- Build script handles heavy setup once
- Runtime script focuses only on execution
- Supports both local development and deployment