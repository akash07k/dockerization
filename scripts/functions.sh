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

# Define a function to backup PostgreSQL database
backup_postgres_db() {
    local project_name="$1"
    local db_container_name="$2"
    local db_username="$3"
    local db_name="$4"
    local should_notify="$5"  # Accept true/false parameter
    local topic="$6"
    local priority="${NTFY_PRIORITY:-low}"  # Set default value "low" if not provided

    local source_backup_file="/tmp/${project_name}_backup.tar"
    local target_backup_file="$HOME/${project_name}_backup.tar"

    # Backup the PostgreSQL database inside the container
    docker exec "$db_container_name" sh -c "pg_dump -U '$db_username' -w -F t -d '$db_name' -f '$source_backup_file'"

    # Check if the backup command succeeded
    if [ $? -eq 0 ]; then
        echo "Database backup succeeded."

        # Copy the backup file from the container to the home directory
        docker cp "$db_container_name:$source_backup_file" "$target_backup_file"

        # Check if the copy command succeeded
        if [ $? -eq 0 ]; then
            echo "The backup file path is $target_backup_file."
            if [ "$should_notify" = "true" ]; then
                notify "The database backup for $project_name is successful, and the backup file path is $target_backup_file." "backup"
            fi
        else
            echo "Failed to copy the backup file for $project_name."
            if [ "$should_notify" = "true" ]; then
                notify "Failed to copy the backup file." "backup"
            fi
        fi
    else
        echo "Database backup failed for $project_name."
        if [ "$should_notify" = "true" ]; then
            notify "Database backup failed for $project_name." "backup"
        fi
    fi
}
