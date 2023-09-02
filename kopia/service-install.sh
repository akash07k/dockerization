#!/bin/bash

# Prompt the user for the Kopia server username and password
read -p "Enter Kopia server username: " KOPIA_USERNAME
read -s -p "Enter Kopia server password: " KOPIA_PASSWORD
echo

# Create a systemd service unit file
cat <<EOF > /etc/systemd/system/kopia-server.service
[Unit]
Description=Kopia Server Service

[Service]
ExecStart=/usr/local/bin/kopia server start --address 0.0.0.0:51515 --tls-cert-file /home/akash/kopia.cert --tls-key-file /home/akash/kopia.key --server-username=\$KOPIA_USERNAME --server-password=\$KOPIA_PASSWORD --enable-actions --refresh-interval=24h
Restart=always
User=akash
WorkingDirectory=/home/akash
Environment="KOPIA_USERNAME=$KOPIA_USERNAME" "KOPIA_PASSWORD=$KOPIA_PASSWORD"

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd configuration
systemctl daemon-reload

# Enable and start the service
systemctl enable kopia-server.service
systemctl start kopia-server.service

# Print service status
systemctl status kopia-server.service
