#!/bin/bash
#Version 1.9.1

# File to store node list for pssh. "sudo nano .pssh_hosts" to create.
NODE_FILE=".pssh_hosts"

# Read compute node hostnames/IPs (with user) from NODE_FILE into an array
if [[ ! -f $NODE_FILE ]]; then
    echo "$(date '+%F %T') ERROR: Node file $NODE_FILE does not exist!"
    exit 1
fi

# Enumerate hostnames/IPs into COMPUTE_NODES variable
readarray -t COMPUTE_NODES < "$NODE_FILE"

# Shutdown all compute nodes in parallel using pssh
#parallel-ssh -i -h $NODE_FILE -l "$SSH_USER" -- sudo shutdown -h now

# Shutdown all compute nodes in parallel using pssh
echo "$(date '+%F %T') Sending shutdown commands to compute nodes..."
parallel-ssh -h "$NODE_FILE" -i -- sudo shutdown -h now

# Wait until all compute nodes are offline, max 20 retries
echo "$(date '+%F %T') Waiting for all compute nodes to shut down..."
MAX_RETRIES=20
RETRY=0

while (( RETRY < MAX_RETRIES )); do
    ALL_DOWN=1
    for NODE_ENTRY in "${COMPUTE_NODES[@]}"; do
        # Extract host from entry: user@host
        HOST=$(echo "$NODE_ENTRY" | awk -F'@' '{print $2}')
        # If entry is just a host with no user, use the whole string
        if [ -z "$HOST" ]; then
            HOST="$NODE_ENTRY"
        fi
        ping -4 -c 1 -W 1 "$HOST" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "$(date '+%F %T') $HOST is still reachable..."
            ALL_DOWN=0
        fi
    done
    if (( ALL_DOWN )); then
        break
    fi
    ((RETRY++))
    sleep 5
done

if (( ALL_DOWN )); then
    echo "$(date '+%F %T') All compute nodes are offline."
else
    echo "$(date '+%F %T') WARNING: Some nodes did not shut down after $((MAX_RETRIES * 5)) seconds."
fi

# Shutdown head node locally
echo "$(date '+%F %T') Shutting down head node..."
sudo shutdown -h now

echo "Cluster shutdown initiated."
