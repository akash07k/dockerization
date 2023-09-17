#!/bin/bash

# Step 1: Deactivate DNSStubListener and update DNS server address
echo "[Resolve]" | sudo tee /etc/systemd/resolved.conf.d/adguardhome.conf
echo "DNS=127.0.0.1" | sudo tee -a /etc/systemd/resolved.conf.d/adguardhome.conf
echo "DNSStubListener=no" | sudo tee -a /etc/systemd/resolved.conf.d/adguardhome.conf

# Step 2: Specify 127.0.0.1 as DNS server address

# Step 3: Activate another resolv.conf file
sudo mv /etc/resolv.conf /etc/resolv.conf.backup
sudo mkdir -p /etc/systemd/resolved.conf.d
sudo cp /home/akash/dockerization/adguardhome/adguardhome.conf /etc/systemd/resolved.conf.d/
sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf

# Step 4: Restart DNSStubListener
sudo systemctl reload-or-restart systemd-resolved

# Additional information
echo "Step 1: DNSStubListener deactivated and DNS server address updated."
echo "Step 2: DNS server address set to 127.0.0.1."
echo "Step 3: Resolv.conf file activated."
echo "Step 4: DNSStubListener restarted."
echo "Please make sure everything is working as expected."

exit 0
