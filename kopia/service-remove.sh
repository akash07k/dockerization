#!/bin/bash

# Remove the service
sudo systemctl stop kopia-server
sudo systemctl disable kopia-server
sudo rm /etc/systemd/system/kopia-server.service
sudo systemctl daemon-reload

# Run the 'kopia server stop' command
kopia server shutdown --address http://0.0.0.0:51515

# Optionally, you can also delete the service files if they are no longer needed
sudo rm /usr/lib/systemd/system/kopia-server
sudo rm /etc/systemd/system/kopia-server
sudo systemctl reset-failed
