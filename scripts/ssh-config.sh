#!/bin/bash

BASTION_IP=$(terraform output -raw bastion-ip)
JENKINS_SLAVE_IP=$(terraform output -raw slave-ip)
NODE_APP_1=$(terraform output -raw node1-ip)
NODE_APP_2=$(terraform output -raw node2-ip)
SSH_CONFIG="$HOME/.ssh/config"

echo "
Host bastion
    HostName $BASTION_IP
    User ubuntu
    IdentityFile ~/.ssh/mykey
" >> "$SSH_CONFIG"

echo "
Host jenkins-slave
    HostName $JENKINS_SLAVE_IP
    User ubuntu
    IdentityFile ~/.ssh/mykey
    ProxyJump bastion
" >> "$SSH_CONFIG"

echo "
Host node1
    HostName $NODE_APP_1
    User ubuntu
    IdentityFile ~/.ssh/mykey
    ProxyJump bastion
" >> "$SSH_CONFIG"

echo "
Host node2
    HostName $NODE_APP_2
    User ubuntu
    IdentityFile ~/.ssh/mykey
    ProxyJump bastion
" >> "$SSH_CONFIG"

chmod 600 "$SSH_CONFIG"

echo "Done"