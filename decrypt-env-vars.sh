#!/bin/bash

# Get the current directory
current_directory=$(pwd)

# Find all subdirectories in the current directory, excluding .git directory
subdirectories=$(find "$current_directory" -mindepth 1 -type d -not -path "$current_directory/.git*")

# Loop through each subdirectory and execute the sops command
for dir in $subdirectories; do
  if [ -f "$dir/default.env" ]; then
    cd "$dir" || exit
    sops -d default.env > .env
    cd "$current_directory" || exit
    echo "Processed: $dir/default.env"
  else
    echo "Skipped: $dir (default.env not found)"
  fi
done
