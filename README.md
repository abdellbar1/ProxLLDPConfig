# Proxmox LLDP Configuration Guide

This guide provides detailed instructions on how to set up the Link Layer Discovery Protocol (LLDP) on a Proxmox server, enable additional protocols such as Cisco Discovery Protocol (CDP), and configure automated updates for network interface descriptions based on LLDP data.

## Prerequisites

Before starting, ensure that you have administrative access to your Proxmox server and are familiar with basic Linux command line operations.

## Installation of LLDP

LLDP is not installed by default on Proxmox. You will need to install the `lldpd` package, which supports LLDP and other discovery protocols.

1. Update your package list:

    ```bash
    sudo apt update
    ```

2. Install `lldpd`:

    ```bash
    sudo apt install lldpd
    ```

## Configuration of LLDPD

After installation, configure `lldpd` to enable additional discovery protocols and set it to recognize specific interface patterns.

### Enabling Additional Protocols

1. Open the `lldpd` default configuration file:

    ```bash
    sudo nano /etc/default/lldpd
    ```

2. Add or modify the following line to enable CDP and other protocols:

    ```plaintext
    DAEMON_ARGS="-x -c -s -e"
    ```

    - `-x`: Enable LLDP.
    - `-c`: Enable CDP (Cisco Discovery Protocol).
    - `-s`: Enable SONMP (Foundry Discovery Protocol).
    - `-e`: Enable EDP (Extreme Discovery Protocol).

3. Save and close the file.

### Restart LLDPD

Restart the `lldpd` service to apply the changes:

```bash
sudo systemctl restart lldpd

## Configuring Interface Pattern

Configure `lldpd` to monitor only interfaces that match a specific pattern, such as `en*` for Ethernet interfaces. This is especially useful in environments with multiple interface types where you want to target a specific subset.

### Set the Interface Pattern

1. Use `lldpcli` to configure the system to monitor interfaces that match the `en*` pattern. This command tells `lldpd` to apply its configuration only to interfaces whose names start with `en`.

    ```bash
    sudo lldpcli configure system interface pattern en*
    ```

2. To verify that the interface pattern has been set correctly, you can display the current configuration of `lldpd`:

    ```bash
    sudo lldpcli show configuration
    ```

This setup ensures that `lldpd` will focus on Ethernet interfaces (like `eno0`, `ens2f1`, etc.), which are typically used in server environments, and will ignore other types of interfaces that do not match the specified pattern.

## Automating Interface Description Updates

Create a cron script that updates the network interface descriptions based on LLDP information.

### Creating the Script

1. **Create a new script file**:
   Open a terminal and use the following command to create a new script file:

    ```bash
    sudo nano /usr/local/bin/update_interface_desc.sh
    ```

2. **Paste the code from the `update_interface_desc.sh` file**, adjusting paths and commands as necessary. Here is a basic example of what the script might include:



3. **Make the script executable**:
   Grant execute permissions to the script using the following command:

    ```bash
    sudo chmod +x /usr/local/bin/update_interface_desc.sh
    ```

### Updating the Cron Job

1. **Edit the root's crontab**:
   Access the cron job editor for the root user by executing:

    ```bash
    sudo crontab -e
    ```

2. **Add the following line to run the script every hour**:
   Schedule the script to run at the start of every hour, and direct the output to a log file for later review:

    ```plaintext
    0 * * * * /usr/local/bin/update_interface_desc.sh >> /var/log/update_interface_desc.log 2>&1
    ```

This setup ensures that your Proxmox server's network interface descriptions are regularly updated based on the latest LLDP data, enhancing network management and documentation.
