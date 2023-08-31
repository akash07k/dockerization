#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Check if the `.env` file exists
if [ -f "$SCRIPT_DIR/.env" ]; then
    # Load the environment variables from the file
    source "$SCRIPT_DIR/.env"
    echo ".env file loaded"
else
    echo ".env file not found"
fi

# Define a function to stop a container
stop_container() {
    local container_name="$1"
    local should_notify="$2"  # Accept true/false parameter
    local topic="$3"
    local priority="${NTFY_PRIORITY:-low}"  # Set default value "low" if not provided
    
    docker stop "$container_name"
    
    # Check the exit code of the container stop command
    if [ $? -eq 0 ]; then
        echo "Docker container '$container_name' stopped successfully."
        if [ "$should_notify" = "true" ]; then
            notify "Container '$container_name' has been stopped." "$topic" "$priority"
        fi
    else
        echo "Failed to stop Docker container '$container_name'."
        if [ "$should_notify" = "true" ]; then
            notify "Container '$container_name' could not be stopped." "$topic"
        fi
    fi
}

# Define a function to start a container
start_container() {
    local container_name="$1"
    local should_notify="$2"  # Accept true/false parameter
    local topic="$3"
    local priority="${NTFY_PRIORITY:-low}"  # Set default value "low" if not provided
    
    docker start "$container_name"
    
    # Check the exit code of the container start command
    if [ $? -eq 0 ]; then
        echo "Docker container '$container_name' started successfully."
        if [ "$should_notify" = "true" ]; then
            notify "Container '$container_name' has been started." "$topic" "$priority"
        fi
    else
        echo "Failed to start Docker container '$container_name'."
        if [ "$should_notify" = "true" ]; then
            notify "Container '$container_name' could not be started." "$topic"
        fi
    fi
}

# Define a function to send a notification
notify() {
    if [ -z "$NTFY_URL" ]; then
        local url="ntfy.techromantica.com"
    else
        local url="$NTFY_URL"
    fi
    
    local message="$1"
    local topic="$2"
    local priority="${NTFY_PRIORITY:-low}"  # Set default value "low" if not provided
    
    curl -u "$NTFY_USERNAME:$NTFY_PASSWORD" -H "Priority: $priority" -d "$message" "$url/$topic-ntfy"

    # Check the exit code of the curl command
    if [ $? -eq 0 ]; then
        echo "Notification sent successfully."
    else
        echo "Failed to send notification."
    fi
}
