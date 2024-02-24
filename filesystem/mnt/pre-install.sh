#!/usr/bin/env bash

echo "Pre-install system tools"

apt-get update
apt-get install -y \
 vim curl htop netcat-traditional \
 openssl net-tools
