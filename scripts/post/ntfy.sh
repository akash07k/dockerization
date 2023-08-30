#!/bin/bash

# Include the functions file
source ../functions.sh

# Define an array of container names
containers=("ntfy")

# Iterate through the container names and start each container
for container in "${containers[@]}"; do
    start_container "$container" "backup" "low"
done
