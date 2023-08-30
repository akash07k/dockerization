#!/bin/bash

# Include the functions file
source ../functions.sh

# Define an array of container names
containers=("linkding")

# Iterate through the container names and stop each container
for container in "${containers[@]}"; do
    stop_container "$container"
done
