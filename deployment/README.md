# Deployment Scripts

This folder contains various deployment scripts for the Twitch Chat Reader application.

## Core Scripts (for main deployment)

- **`start-app.sh`** - Direct start script used by the main `run` command
- **`deploy.sh`** - Comprehensive deployment script with Java detection

## Alternative Build Scripts

- **`build-replit.sh`** - Replit-specific build script using system Java
- **`run-simple.sh`** - Simple deployment script without package installation
- **`build-fast.sh`** - Fast build script for quick compilation
- **`build-simple.sh`** - Simple build without verbose output
- **`build-deploy.sh`** - Deployment-ready build script
- **`build-final.sh`** - Final optimized build script
- **`build-deployment.sh`** - Alternative deployment build

## Configuration Files

- **`replit_deps.txt`** - Replit dependencies specification

## Usage

The main application uses `deployment/start-app.sh` via the root `run` script. Other scripts are available for specific deployment scenarios or troubleshooting.

## Permission Fixes Applied

All scripts have been updated to:
- Use only Replit's system Java (no portable installations)
- Avoid package installation during deployment
- Handle permission issues gracefully
- Provide fallback execution methods