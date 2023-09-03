#!/bin/bash

# Create a systemd service unit file
sudo tee /etc/systemd/system/kopia-server.service <<EOF
[Unit]
Description=Kopia Server Service

[Service]
ExecStartPre=/bin/bash -c 'sudo setcap cap_dac_read_search=+ep /usr/bin/kopia'
ExecStartPre=/bin/bash -c 'sudo setcap cap_dac_override=+ep /usr/bin/kopia'
ExecStart=kopia server start --address http://0.0.0.0:51515 --enable-actions --refresh-interval=24h --without-password --insecure
KillMode=process
StandardOutput=tty
Restart=always
User=akash
WorkingDirectory=/home/akash

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
