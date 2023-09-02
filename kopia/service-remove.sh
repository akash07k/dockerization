#!/bin/bash

# Remove the service
systemctl stop kopia-server
systemctl disable kopia-server
rm /etc/systemd/system/kopia-server.service
systemctl daemon-reload

# Run the 'kopia server stop' command
kopia server stop

# Optionally, you can also delete the service files if they are no longer needed
rm /usr/lib/systemd/system/kopia-server
rm /etc/systemd/system/kopia-server
