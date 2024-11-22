#!/bin/bash

# Function to detect the subnet
get_subnet() {
    # Use the `ip` command if available
    if command -v ip &>/dev/null; then
        ip addr | grep -oP 'inet\s+\K\d+\.\d+\.\d+\.\d+/\d+' | grep -v '127.0.0.1' | head -n 1
        return
    fi

    # Fallback to `ifconfig` if `ip` is not available
    if command -v ifconfig &>/dev/null; then
        ip=$(ifconfig | grep -oP 'inet\s+\K\d+\.\d+\.\d+\.\d+' | grep -v '127.0.0.1' | head -n 1)
        netmask=$(ifconfig | grep -oP 'netmask\s+\K\d+\.\d+\.\d+\.\d+' | head -n 1)
        if [ -n "$ip" ] && [ -n "$netmask" ]; then
            # Convert netmask to CIDR
            IFS='.' read -r -a mask <<<"$netmask"
            cidr=0
            for octet in "${mask[@]}"; do
                cidr=$((cidr + $(echo "obase=2; $octet" | bc | grep -o 1 | wc -l)))
            done
            echo "$ip/$cidr"
            return
        fi
    fi

    echo "Failed to detect subnet."
    exit 1
}

# Function to scan subnet for open port 80
scan_port_80() {
    local subnet=$1
    echo "Scanning subnet $subnet for devices with port 80 open..."
    nmap -p 80 --open "$subnet" | grep "Nmap scan report for" | awk '/Nmap scan report for/ {print $NF}' | tr -d '()'
}

# Function to check if a device is an Axis camera
check_axis_camera() {
    local ip=$1
    response=$(curl -s -m 5 http://$ip)

    if echo "$response" | grep -q "<script>window.location.pathname='camera/index.html'</script>"; then
        echo "$ip appears to be an Axis camera."
    fi
}

# Main script execution
subnet=$(get_subnet)

if [ -z "$subnet" ]; then
    echo "Could not determine subnet."
    exit 1
fi

open_hosts=$(scan_port_80 "$subnet")

if [ -n "$open_hosts" ]; then
    echo "Checking devices for Axis cameras..."
    echo

    # Check each device for Axis camera identifier
    for ip in $open_hosts; do
        check_axis_camera "$ip"
    done
else
    echo "No devices with port 80 open found."
fi
