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
        notify "Container '$container_name' has been stopped." "$should_notify" "$topic" "$priority"
    else
        notify "Container '$container_name' could not be stopped." "$should_notify" "$topic"  "$priority"
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
        notify "Container '$container_name' has been started." "$should_notify" "$topic" "$priority"
    else
        notify "Container '$container_name' could not be started." "$should_notify" "$topic"  "$priority"
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

    local source_backup_dir="/tmp/${project_name}_backup"
    local target_backup_file="$HOME/${project_name}_backup"

    # Debugging output
    echo "Source backup dir: $source_backup_dir"

    # Check if the source backup directory exists within the container
    if docker exec "$db_container_name" test -d "$source_backup_dir"; then
        echo "Source backup directory exists within the container."

        # Delete the source backup directory within the container
        if docker exec "$db_container_name" rm -rf "$source_backup_dir"; then
            echo "Deleted existing source backup directory within the container: $source_backup_dir"
        else
            notify "Failed to delete existing source backup directory within the container: $source_backup_dir" "$should_notify" "$topic"  "$priority"
            exit 1
        fi
    else
        echo "Source backup directory does not exist within the container."
    fi

    # Create the target backup directory if it doesn't exist
    if [ ! -d "$(dirname "$target_backup_file")" ]; then
        mkdir -p "$(dirname "$target_backup_file")"
        if [ $? -eq 0 ]; then
            echo "Created target backup directory: $(dirname "$target_backup_file")"
        else
            notify "Failed to create target backup directory: $(dirname "$target_backup_file")" "$should_notify" "$topic"  "$priority"
            exit 1
        fi
    fi

    # Backup the PostgreSQL database inside the container
    docker exec "$db_container_name" sh -c "pg_dump -U $db_username -w -F d -d $db_name -f $source_backup_dir"

    # Check if the backup command succeeded
    if [ $? -eq 0 ]; then
        echo "Database backup succeeded."

        # Copy the backup file from the container to the home directory
        docker cp "$db_container_name:$source_backup_dir" "$target_backup_file"

        # Check if the copy command succeeded
        if [ $? -eq 0 ]; then
            notify "The database backup for $project_name is successful, and the backup file path is $target_backup_file." "$should_notify" "$topic"  "$priority"
        else
            notify "Failed to copy the backup file for $project_name." "$should_notify" "$topic"  "$priority"
        fi
    else
        notify "Database backup failed for $project_name." "$should_notify" "$topic"  "$priority"
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
    local should_notify="$2"  # Accept true/false parameter
    local topic="$3"
    local priority="${NTFY_PRIORITY:-low}"  # Set default value "low" if not provided
    
    echo "$message"
    
    if [ "$should_notify" = "true" ]; then    
        curl -u "$NTFY_USERNAME:$NTFY_PASSWORD" -H "Priority: $priority" -d "$message" "$url/$topic-ntfy"
    fi

    # Check the exit code of the curl command
    if [ $? -eq 0 ]; then
        echo "Notification sent successfully."
    else
        echo "Failed to send notification."
    fi
}
