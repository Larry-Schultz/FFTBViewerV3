#!/bin/bash

# Debug script to diagnose deployment environment
echo "=== Deployment Environment Debug ==="
echo "Current directory: $(pwd)"
echo "Script name: $0"
echo "PATH: $PATH"
echo ""

echo "Looking for 'run' command:"
which run 2>/dev/null || echo "run not found in PATH"
echo ""

echo "Checking various locations for run script:"
for path in "./run" "/home/runner/workspace/run" "~/.local/bin/run" "/usr/bin/run" "/bin/run"; do
    if [ -f "$path" ]; then
        echo "✓ Found: $path"
        ls -la "$path"
    else
        echo "✗ Missing: $path"
    fi
done
echo ""

echo "Directory contents:"
ls -la
echo ""

echo "Java environment:"
echo "JAVA_HOME: ${JAVA_HOME:-not set}"
java -version 2>&1 || echo "Java not found"
echo ""

echo "Attempting to execute deployment command:"
echo "Command: sh -c 'run'"
sh -c 'run' || echo "Failed to execute run command"