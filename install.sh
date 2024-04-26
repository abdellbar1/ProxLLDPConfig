#!/bin/bash

# ----------------------------------------------------------------------------
# Script to Update Network Interface Descriptions Based on LLDP Information
# Developer: Abdelbar Aglagane
# Email: abdellbar@gmail.com
# 
# DISCLAIMER:
# This script is provided "AS IS", without warranty of any kind, express or
# implied, including but not limited to the warranties of merchantability,
# fitness for a particular purpose and noninfringement. In no event shall the
# authors or copyright holders be liable for any claim, damages or other
# liability, whether in an action of contract, tort or otherwise, arising from,
# out of or in connection with the script or the use or other dealings in the
# script.
#
# LICENSE:
# This script is part of the "ProxLLDPConfig" repository and governed by the
# terms of the repository's license agreement. Unauthorized copying of this file,
# via any medium is strictly prohibited and the file may not be modified or
# distributed without the permission of the copyright holder.
# ----------------------------------------------------------------------------

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "Updating package lists..."
sudo apt update

echo "Installing lldpd..."
sudo apt install lldpd -y

echo "Configuring lldpd to enable additional protocols..."
echo 'DAEMON_ARGS="-x -c -s -e"' | sudo tee /etc/default/lldpd

echo "Restarting lldpd service..."
sudo systemctl restart lldpd

echo "Configuring lldpd to monitor all interfaces matching '*' pattern..."
sudo lldpcli configure system interface pattern *

# Assuming the update_interface_desc.sh is in the same directory as install.sh
# Copy the update_interface_desc.sh script to /usr/local/bin
echo "Copying the update_interface_desc.sh script to /usr/local/bin..."
sudo cp update_interface_desc.sh /usr/local/bin/update_interface_desc.sh
sudo chmod +x /usr/local/bin/update_interface_desc.sh

echo "Creating cron job for updating interface descriptions..."
(crontab -l 2>/dev/null; echo "0 * * * * /usr/local/bin/update_interface_desc.sh >> /var/log/update_interface_desc.log 2>&1") | crontab -

echo "Installation and configuration completed successfully."
