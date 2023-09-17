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

# Define the ports to allow
PORTS_TO_ALLOW=("853/tcp" "853/udp" "784/udp" "8853/udp" "5443/tcp" "5443/udp" "$HOST_HTTP_PORT/tcp" "$HOST_HTTPS_PORT/tcp" "$HOST_HTTPS_PORT/udp" "$HOST_ADMIN_PANEL_PORT/tcp" "openssh")

# Allow the specified ports via ufw
for port in "${PORTS_TO_ALLOW[@]}"; do
    ufw allow "$port"
done

# Enable ufw (if not already enabled)
ufw --force enable

# Reload the firewall rules
ufw reload

# Display the current ufw rules
ufw status verbose
