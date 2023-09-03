#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Include the functions file using an absolute path
source "$SCRIPT_DIR/../functions.sh"

# Define an array of container names
containers=("portainer")

# Iterate through the container names and start each container
for container in "${containers[@]}"; do
    start_container "$container" true "backup" "low" "Container '$container' has been started."
done
