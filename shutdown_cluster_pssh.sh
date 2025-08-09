#!/bin/bash

# List of compute node hostnames or IPs (space-separated)
COMPUTE_NODES="rpi1 rpi2"   # <-- Edit with your node hostnames/IPs

# SSH username
SSH_USER="pi"                        # <-- Edit your SSH username

# Optional: file to store node list for pssh
NODE_FILE=".pssh_hosts"

# Write compute nodes to file for pssh
echo "${COMPUTE_NODES// /$'\n'}" > $NODE_FILE

# Shutdown all compute nodes in parallel using pssh
pssh -h $NODE_FILE -l "$SSH_USER" -i "sudo shutdown -h now"

# Wait until all compute nodes are offline
echo "Waiting for all compute nodes to shut down..."

ALL_DOWN=0
while [ $ALL_DOWN -eq 0 ]; do
    ALL_DOWN=1
    for NODE in $COMPUTE_NODES; do
        ping -c 1 -W 2 $NODE >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "$NODE is still reachable..."
            ALL_DOWN=0
        fi
    done
    if [ $ALL_DOWN -eq 0 ]; then
        echo "Some nodes are still up. Retrying in 5 seconds..."
        sleep 5
    fi
done

echo "All compute nodes are offline."

# Shutdown head node locally
echo "Shutting down head node..."
sudo shutdown -h now

echo "Cluster shutdown initiated."