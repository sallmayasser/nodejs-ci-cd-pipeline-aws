#!/bin/bash

TF_OUTPUT_FILE="tf-output.json"
HOSTS_FILE="../ansible/inventory"

# Extract IPs using jq
bastion_ip=$(jq -r '.["bastion-ip"].value' "$TF_OUTPUT_FILE")
jenkins_slaves=$(jq -r '.["slave-ip"].value' "$TF_OUTPUT_FILE")
node_app_1=$(jq -r '.["node1-ip"].value' "$TF_OUTPUT_FILE")
node_app_2=$(jq -r '.["node2-ip"].value' "$TF_OUTPUT_FILE")

# Start writing the hosts file
cat <<EOF > "$HOSTS_FILE"
[bastion]
$bastion_ip

[jenkins_slaves]
slave1  ansible_host=jenkins-slave 

[node_apps]
node1 ansible_host=$node_app_1
node2 ansible_host=$node_app_2


[all:vars]
ansible_user=ubuntu

EOF

echo "✅ Inventory generated at $HOSTS_FILE"
