#!/bin/bash

# Check if KOPIA_USERNAME and KOPIA_PASSWORD are already set
if [ -z "$KOPIA_USERNAME" ] || [ -z "$KOPIA_PASSWORD" ]; then
    # Prompt the user for the Kopia server username and password
    read -p "Enter Kopia server username: " KOPIA_USERNAME
    read -s -p "Enter Kopia server password: " KOPIA_PASSWORD
    echo

    # Add the environment variables to ~/.bashrc
    echo "export KOPIA_USERNAME=\"$KOPIA_USERNAME\"" >> ~/.bashrc
    echo "export KOPIA_PASSWORD=\"$KOPIA_PASSWORD\"" >> ~/.bashrc

    # Reload ~/.bashrc to make the variables available in the current session
    source ~/.bashrc
else
    echo "KOPIA_USERNAME and KOPIA_PASSWORD are already set."
fi

# Create a systemd service unit file
sudo tee /etc/systemd/system/kopia-server.service <<EOF
[Unit]
Description=Kopia Server Service

[Service]
ExecStart=/usr/bin/kopia server start --address http://0.0.0.0:51515 --server-username=$KOPIA_USERNAME --server-password=$KOPIA_PASSWORD --enable-actions --refresh-interval=24h --insecure
Restart=always
User=akash
WorkingDirectory=/home/akash
Environment="KOPIA_USERNAME=\$KOPIA_USERNAME" "KOPIA_PASSWORD=\$KOPIA_PASSWORD"

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd configuration
sudo systemctl daemon-reload

# Enable and start the service
sudo systemctl enable kopia-server.service
sudo systemctl start kopia-server.service

# Print service status
sudo systemctl status kopia-server.service
