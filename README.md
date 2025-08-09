Install on the head node of your Raspberry Pi Cluster. (Only tested on a head node running the latest bookworm with pssh installed.)
As published, the program expects your sub nodes to have the user name "pi" and have been added to ".pssh_hosts" with the command "sudo nano .pssh_hosts".
These settings can be changed by modifying the code.
Run with "sudo bash shutdown_cluster_pssh.sh" on the head node of your cluster.
