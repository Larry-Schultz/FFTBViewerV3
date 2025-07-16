#!/bin/bash

# Ultimate deployment runner that handles all possible deployment scenarios
# This script can be called as 'run', './run', or directly from deployment

set -e  # Exit on any error

echo "=== Deployment Runner - Finding Project ==="

# Function to find and execute the project
find_and_run_project() {
    local search_paths=(
        "/home/runner/workspace"
        "$(pwd)"
        "$(dirname "$0")"
    )
    
    for path in "${search_paths[@]}"; do
        if [ -f "$path/pom.xml" ]; then
            echo "Found project at: $path"
            cd "$path"
            
            # Try start.sh first (our enhanced script), then run
            if [ -f "./start.sh" ]; then
                echo "Executing enhanced start.sh script..."
                exec ./start.sh "$@"
            elif [ -f "./run" ]; then
                echo "Executing run script..."
                exec ./run "$@"
            else
                echo "ERROR: No execution script found in project directory"
                exit 1
            fi
        fi
    done
    
    echo "ERROR: Could not find project directory with pom.xml"
    echo "Searched paths:"
    for path in "${search_paths[@]}"; do
        echo "  - $path"
    done
    exit 1
}

# Execute the project finder
find_and_run_project "$@"