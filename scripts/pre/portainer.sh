#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Include the functions file using an absolute path
source "$SCRIPT_DIR/../functions.sh"

# Define an array of container names
containers=("portainer")

# Iterate through the container names and stop each container
for container in "${containers[@]}"; do
    stop_container "$container" true "pre-backup" "low" "Container '$container' has been stopped."
done
