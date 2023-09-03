#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Include the functions file using an absolute path
source "$SCRIPT_DIR/../functions.sh"

# Define an array of container names
containers=("ntfy")

# Iterate through the container names and start each container
for container in "${containers[@]}"; do
    start_container "$container" true "post-backup" "low" "Container '$container' backup is complete. Container has been started."
done
