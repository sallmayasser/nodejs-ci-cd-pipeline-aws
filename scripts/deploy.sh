#!/bin/bash

set -e

username=$1
password=$2
ssh_key_path=~/.ssh/mykey
echo "📦 Running Terraform..."
cd terraform
terraform apply -var db_username=$username -var db_password=$password -auto-approve

echo "📤 Extracting Terraform outputs..."
terraform output -json >../scripts/tf-output.json

echo "⚙️ Generating Ansible inventory..."
bash ../scripts/inventory-gen.sh

echo "🔑 configure the SSH keys ..."
bash ../scripts/ssh-config.sh

echo "🚀 Running Ansible playbook..."
cd ../ansible
ansible-playbook playbook.yaml

echo "🔁 Enable port forwarding on Bastion Host ..."
ssh bastion <<EOF
  sudo sed -i '/^GatewayPorts/d;/^AllowTcpForwarding/d' /etc/ssh/sshd_config
  echo "GatewayPorts yes" | sudo tee -a /etc/ssh/sshd_config
  echo "AllowTcpForwarding yes" | sudo tee -a /etc/ssh/sshd_config
  sudo systemctl restart sshd
EOF

echo "🔁 Starting reverse SSH tunnel from local to Bastion Host..."
ssh -i ${ssh_key_path} -o "ExitOnForwardFailure=yes" -f -N -R 8080:localhost:8080 bastion

echo "✅ All done!"
