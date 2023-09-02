#!/bin/bash

# Prompt the user for KOPIA_USERNAME and store it in the environment variable
read -p "Enter KOPIA_USERNAME: " KOPIA_USERNAME

# Prompt the user for KOPIA_PASSWORD and store it in the environment variable
read -s -p "Enter KOPIA_PASSWORD: " KOPIA_PASSWORD
echo # Print a newline after password input

# Add or modify the export statements in the user's profile configuration
echo "export KOPIA_USERNAME=\"$KOPIA_USERNAME\"" >> ~/.bashrc
echo "export KOPIA_PASSWORD=\"$KOPIA_PASSWORD\"" >> ~/.bashrc

# Reload the user's profile to make the environment variables available
source ~/.bashrc

# Run the kopia command
kopia server start --address 0.0.0.0:51515 --tls-generate-cert --tls-cert-file ~/kopia.cert --tls-key-file ~/kopia.key --server-username="$KOPIA_USERNAME" --server-password="$KOPIA_PASSWORD" --enable-actions --refresh-interval=24h
