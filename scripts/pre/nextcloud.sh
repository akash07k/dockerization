#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Include the functions file using an absolute path
source "$SCRIPT_DIR/../functions.sh"

project_name="nextcloud"
# Define an array of container names
containers=("nextcloud-app")
db_container_name="nextcloud-db"
db_username="akash"
db_name="nextcloud"

# Iterate through the container names and stop each container
for container in "${containers[@]}"; do
    stop_container "$container" true "pre-backup" "low" "Container '$container' has been stopped."
    backup_postgres_db "$project_name" "$db_container_name" "$db_username" "$db_name" true "pre-backup" "low"
done
