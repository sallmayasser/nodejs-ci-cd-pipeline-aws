#!/bin/bash

BASTION_IP=$(terraform output -raw bastion-ip)
JENKINS_SLAVE_IP=$(terraform output -raw slave-ip)
NODE_APP_1=$(terraform output -raw node1-ip)
NODE_APP_2=$(terraform output -raw node2-ip)

SSH_CONFIG="$HOME/.ssh/config"
NODE_SSH_CONFIG="../scripts/nodes-config"


BASTION_BLOCK="
Host bastion
    HostName $BASTION_IP
    User ubuntu
    IdentityFile ~/.ssh/mykey
"

echo "$BASTION_BLOCK" >>"$SSH_CONFIG"
echo "$BASTION_BLOCK" >>"$NODE_SSH_CONFIG"


echo "
Host jenkins-slave
    HostName $JENKINS_SLAVE_IP
    User ubuntu
    IdentityFile ~/.ssh/mykey
    ProxyJump bastion
" >>"$SSH_CONFIG"


# add the node server in separate file to run it on jenkins slave

echo "
Host node1
    HostName $NODE_APP_1
    User ubuntu
    IdentityFile ~/.ssh/mykey
    ProxyJump bastion
" >>"$NODE_SSH_CONFIG"

echo "
Host node2
    HostName $NODE_APP_2
    User ubuntu
    IdentityFile ~/.ssh/mykey
    ProxyJump bastion
" >>"$NODE_SSH_CONFIG"

chmod 600 "$SSH_CONFIG"

echo "✅ SSH config written to:"
echo "- Main config: $SSH_CONFIG"
echo "- Node-only config: $NODE_SSH_CONFIG"
