#!/usr/bin/env bash
: "${SSH_AUTHORIZED_KEYS?}"

apt-get install -y openssh-server

ssh-keygen -t rsa -b 4096 -C "root@k3s" -f ~/.ssh/id_rsa -q -N ""

echo $SSH_AUTHORIZED_KEYS | base64 --decode > ~/.ssh/authorized_keys
