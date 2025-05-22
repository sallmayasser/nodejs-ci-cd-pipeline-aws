#!/bin/bash

TF_OUTPUT_FILE="../scripts/tf-output.json"
HOSTS_FILE="../ansible/inventory"

# Extract IPs using jq
bastion_ip=$(jq -r '.["bastion-ip"].value' "$TF_OUTPUT_FILE")

# Start writing the hosts file
# [bastion]
# bastion ansible_host=bastion
cat <<EOF > "$HOSTS_FILE"

[jenkins_slaves]
slave1  ansible_host=jenkins-slave 

[node_apps]
node1 ansible_host=node1
node2 ansible_host=node2


[all:vars]
ansible_user=ubuntu

EOF

echo "✅ Inventory generated at $HOSTS_FILE"
