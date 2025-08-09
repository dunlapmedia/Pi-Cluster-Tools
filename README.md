Shutdown Cluster Bash Script

Version 1.2

Install on the head node of your Raspberry Pi Cluster. (Only tested on a head node running the latest bookworm with pssh installed.)

As published, the program expects your subnodes to have the same username, "pi", and have been added (return delimited) to ".pssh_hosts" with the command "sudo nano .pssh_hosts".

These settings can be changed by modifying the code.

Run with "sudo bash shutdown_cluster_pssh.sh" on the head node of your cluster.

Change Log:
V 1.2: Simplified code for easier customization.
V 1.1: Added Parallel-ssh utilization
