#!/bin/bash
# set -e
while getopts "i:" opt; do
 case $opt in
   i) allowed_ip=$OPTARG;;
 esac
done

# Install required packages
export DEBIAN_FRONTEND=noninteractive
apt-get -o DPkg::Lock::Timeout=60 update
apt-get -o DPkg::Lock::Timeout=60 install -y ufw

# Hardening
ufw --force enable
echo $allowed_ip > /root/allowed_ip.txt
ufw allow from $allowed_ip
ufw allow to $allowed_ip

# Reboot (recommended by CUDA installers and to enable UFW)
# reboot
