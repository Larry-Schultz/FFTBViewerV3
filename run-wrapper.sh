#!/bin/bash

# Simple wrapper script to handle deployment execution
# This addresses the issue where 'sh run' can't find the run script

# Change to the correct directory (in case we're not in project root)
cd "$(dirname "$0")"

# Execute the run script with proper path
exec ./run "$@"