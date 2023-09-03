#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Include the functions file using an absolute path
source "$SCRIPT_DIR/../functions.sh"

project_name="drupal"
# Define an array of container names
containers=("drupal-app")
db_container_name="drupal-db"
db_username="akash"
db_name="drupal"

# Iterate through the container names and stop each container
for container in "${containers[@]}"; do
    stop_container "$container" true "backup" "low"
    backup_postgres_db "$project_name" "$db_container_name" "$db_username" "$db_name" true "backup" "low"
done
