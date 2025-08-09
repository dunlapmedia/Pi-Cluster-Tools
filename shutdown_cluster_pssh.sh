#!/bin/bash
#Version 1.2

# File to store node list for pssh. "sudo nano .pssh_hosts" to create.
NODE_FILE=".pssh_hosts"

# Read compute node hostnames or IPs from NODE_FILE
if [[ ! -f $NODE_FILE ]]; then
    echo "Node file $NODE_FILE does not exist!"
    exit 1
fi

# Enumerate hostnames/IPs into COMPUTE_NODES variable
COMPUTE_NODES=$(awk '{print $1}' $NODE_FILE)

# SSH username
SSH_USER="pi"                        # <-- Edit your SSH username

# Shutdown all compute nodes in parallel using pssh
parallel-ssh -h $NODE_FILE -l "$SSH_USER" -i "sudo shutdown -h now"

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
