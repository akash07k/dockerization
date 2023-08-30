#!/bin/bash

# Define a function to stop a container
stop_container() {
    local container_name="$1"
    
    docker stop "$container_name"
    
    # Check the exit code of the container stop command
    if [ $? -eq 0 ]; then
        echo "Docker container '$container_name' stopped successfully."
    else
        echo "Failed to stop Docker container '$container_name'."
    fi
}

# Define a function to start a container
start_container() {
    local container_name="$1"
    
    docker start "$container_name"
    
    # Check the exit code of the container start command
    if [ $? -eq 0 ]; then
        echo "Docker container '$container_name' started successfully."
    else
        echo "Failed to start Docker container '$container_name'."
    fi
}
