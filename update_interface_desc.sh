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

# Path to the network interfaces configuration file
INTERFACES_FILE="/etc/network/interfaces"
TEMP_FILE="/tmp/interfaces.new"
LOG_FILE="/var/log/update_interface_desc.log"

# Logging function
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $*" >> $LOG_FILE
}

# Backup the current interfaces file
cp $INTERFACES_FILE $TEMP_FILE
log "Backed up current interfaces file."

# Configure lldpcli to only monitor en* interfaces
lldpcli configure system interface pattern en*
log "Configured lldpcli to monitor interfaces matching 'en*' pattern."

# Function to update interface description
update_description() {
    iface=$1
    descr=$2
    pattern="iface $iface inet"
    if grep -q "^$pattern" $TEMP_FILE; then
        log "Found configuration for $iface."
        # Check if the description already exists
        descr_line="^#\s*$descr"
        if ! grep -q "$descr_line" $TEMP_FILE; then
            # Add the description to the interface definition
            sed -i "/$pattern/a #$descr" $TEMP_FILE
            log "Added description '$descr' to $iface."
        else
            log "Description '$descr' already exists for $iface, skipping."
        fi
    else
        log "No configuration found for $iface, skipping."
    fi
}

# Process each neighbor and extract relevant data
while IFS= read -r line; do
    if [[ "$line" =~ Interface: ]]; then
        iface=$(echo "$line" | awk '{print $2}' | tr -d ',')
    elif [[ "$line" =~ PortDescr: ]]; then
        port_descr=$(echo "$line" | cut -d ' ' -f 2-)
        log "Processing $iface with port description $port_descr."
        update_description "$iface" "$port_descr"
    fi
done < <(lldpcli show neighbors)

# Check for changes and update the original file if needed
if ! cmp -s $TEMP_FILE $INTERFACES_FILE; then
    echo "Updating network interface descriptions..."
    cp $TEMP_FILE $INTERFACES_FILE
    log "Updated the network interface file with new descriptions."
else
    log "No changes to apply."
fi

# Clean up temporary file
rm $TEMP_FILE
log "Cleanup completed."
