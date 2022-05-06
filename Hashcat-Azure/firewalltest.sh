#!/bin/bash
# set -e
# DEBIAN_FRONTEND=noninteractive
# timedatectl set-timezone Europe/Amsterdam
while getopts "i:" opt; do
 case $opt in
   i) allowed_ip=$OPTARG;;
 esac
done

# Install required packages
export DEBIAN_FRONTEND=noninteractive
apt-get -o DPkg::Lock::Timeout=60 update
apt-get -o DPkg::Lock::Timeout=60 -y install ufw

# Hardening
ufw --force enable
echo $allowed_ip > /root/allowed_ip.txt
ufw allow from $allowed_ip
ufw allow to $allowed_ip

# Reboot (recommended by CUDA installers and to enable UFW)
# reboot
