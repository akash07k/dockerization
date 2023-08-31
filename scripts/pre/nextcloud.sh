#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Include the functions file using an absolute path
source "$SCRIPT_DIR/../functions.sh"

# Define an array of container names
containers=("nextcloud-app")

# Iterate through the container names and stop each container
for container in "${containers[@]}"; do
    stop_container "$container" true "backup" "low"
done

project_name="nextcloud"
db_container_name="nextcloud-db"
db_username="akash"
db_name="nextcloud"
source_backup_file="/tmp/${project_name}_backup.tar"
target_backup_file="$HOME/${project_name}_backup.tar"

# Backup the PostgreSQL database inside the container
docker exec $db_container_name sh -c "pg_dump -U ${db_username} -w -F t -d ${db_name} -f ${source_backup_file}"

# Check if the backup command succeeded
if [ $? -eq 0 ]; then
    echo "Database backup succeeded."
    
    # Copy the backup file from the container to the home directory
    docker cp $db_container_name:$source_backup_file $target_backup_file

    # Check if the copy command succeeded
    if [ $? -eq 0 ]; then
        echo "The backup file path is ${target_backup_file}."
        notify "The database backup for $project_name is successful and the backup file path is ${target_backup_file}." "backup"
    else
        echo "Failed to copy backup file for $project_name."
        notify "Failed to copy backup file." "backup"
    fi
else
    echo "Database backup failed for $project_name."
    notify "Database backup failed for $project_name." "backup"
fi
