#!/bin/bash
set -e
DEBIAN_FRONTEND=noninteractive
USER_NAME=RED
WEB_USER=www-data
timedatectl set-timezone Europe/Amsterdam

# Install required packages
export DEBIAN_FRONTEND=noninteractive
apt-get -o DPkg::Lock::Timeout=60 update
apt-get -o DPkg::Lock::Timeout=60 upgrade -y
apt-get -o DPkg::Lock::Timeout=60 install -y linux-headers-$(uname -r) libglvnd-dev pkg-config apt-transport-https build-essential libncurses5-dev software-properties-common git screen python3-venv python3-pip sqlite3 apache2 certbot python3-certbot-apache jq curl p7zip-full cewl ufw
ufw --force disable

# Blacklist nouveau drivers
cat <<EOT >> /etc/modprobe.d/nouveau.conf
blacklist nouveau
blacklist lbm-nouveau
EOT

# Set up CUDA Toolkit: https://developer.nvidia.com/cuda-downloads
wget https://developer.download.nvidia.com/compute/cuda/repos/debian10/x86_64/cuda-keyring_1.0-1_all.deb
sudo dpkg -i cuda-keyring_1.0-1_all.deb
add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/debian10/x86_64/ /"
add-apt-repository contrib
apt-get update
apt-get -y install cuda

# Install Hashcat
HASHCAT_SRC_PKG=hashcat-6.2.5
wget https://hashcat.net/files/${HASHCAT_SRC_PKG}.tar.gz
tar -xf ${HASHCAT_SRC_PKG}.tar.gz
cd ${HASHCAT_SRC_PKG}
make && make install

# Download and generate wordlists
mkdir /opt/wordlists
mkdir /opt/hashes
mkdir /opt/rules
mkdir /opt/masks
wget --quiet -O /opt/wordlists/rockyou.txt https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt
wget --quiet -O /opt/wordlists/tmp.7z https://hashkiller.io/downloads/hashkiller-dict-2020-01-26.7z
wget --quiet -O /opt/wordlists/dutch1_unclean https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/dutch_wordlist
wget --quiet -O /opt/wordlists/dutch2_unclean https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/dutch_passwordlist.txt
wget --quiet -O /opt/wordlists/dutch3_unclean https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/dutch_common_wordlist.txt
wget --quiet -O /opt/wordlists/dutch4_unclean https://raw.githubusercontent.com/beurtschipper/Dutch-Password-List/master/DutchWordlists/Dutch_Massive_Twitter_Wikipedia_Bible.txt
wget --quiet -O /opt/wordlists/dutch5_unclean https://raw.githubusercontent.com/beurtschipper/Dutch-Password-List/master/DutchWordlists/Dutch_FirstNames.txt
wget --quiet -O /opt/wordlists/dutch6_unclean https://raw.githubusercontent.com/beurtschipper/Dutch-Password-List/master/DutchWordlists/Dutch_LastNames.txt
wget --quiet -O /opt/wordlists/dutch7_unclean https://raw.githubusercontent.com/beurtschipper/Dutch-Password-List/master/DutchWordlists/Dutch_Norm_All.txt
wget --quiet -O /opt/wordlists/dutch8_unclean https://github.com/dwyl/english-words/raw/master/words.txt
cewl -d 0 -m 2 -w /opt/wordlists/dutch9_unclean https://nl.wikipedia.org/wiki/Lijst_van_uitdrukkingen_en_gezegden_A-E
cewl -d 0 -m 2 -w /opt/wordlists/dutch10_unclean https://nl.wikipedia.org/wiki/Lijst_van_uitdrukkingen_en_gezegden_F-J
cewl -d 0 -m 2 -w /opt/wordlists/dutch11_unclean https://nl.wikipedia.org/wiki/Lijst_van_uitdrukkingen_en_gezegden_K-O
cewl -d 0 -m 2 -w /opt/wordlists/dutch12_unclean https://nl.wikipedia.org/wiki/Lijst_van_uitdrukkingen_en_gezegden_P-U
cewl -d 0 -m 2 -w /opt/wordlists/dutch13_unclean https://nl.wikipedia.org/wiki/Lijst_van_uitdrukkingen_en_gezegden_V-Z
cat /opt/wordlists/dutch*_unclean | sort | uniq > /opt/wordlists/words.txt
rm /opt/wordlists/dutch*_unclean
7z x /opt/wordlists/tmp.7z -o'/opt/wordlists/'
rm /opt/wordlists/tmp.7z

# Download and merge rules
wget --quiet -O /opt/rules/rule1.rule https://raw.githubusercontent.com/cyclone-github/rules/master/cyclone_250.rule
wget --quiet -O /opt/rules/rule2.rule https://raw.githubusercontent.com/NotSoSecure/password_cracking_rules/master/OneRuleToRuleThemAll.rule
wget --quiet -O /opt/rules/rule3.rule https://raw.githubusercontent.com/hashcat/hashcat/master/rules/dive.rule
wget --quiet -O /opt/rules/rule4.rule https://github.com/beurtschipper/Dutch-Password-List/raw/master/spipbest300.rule
cat /opt/rules/rule*.rule | sort | uniq > /opt/rules/master.rule
rm /opt/rules/rule*.rule

# Download and merge masks
wget --quiet -O /opt/masks/mask1.hcmask https://raw.githubusercontent.com/beurtschipper/Dutch-Password-List/master/spipbestmasks.hcmask
wget --quiet -O /opt/masks/mask2.hcmask https://raw.githubusercontent.com/beurtschipper/Dutch-Password-List/master/spipfollowmasks.hcmask
wget --quiet -O /opt/masks/mask3.hcmask https://raw.githubusercontent.com/xfox64x/Hashcat-Stuffs/master/masks/9_plus_microsoft_complexity_top_5000_masks.txt
cat /opt/masks/mask*.hcmask | sort | uniq > /opt/masks/master.hcmask

# Request SSL certificate
region=$(curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | jq -r '.compute.location')
fqdn="$(hostname).$region.cloudapp.azure.com"
rm /var/www/html/index.html
systemctl start apache2
certbot --apache --non-interactive --agree-tos -m info@ramondunker.nl -d $fqdn
systemctl stop apache2
systemctl disable apache2

# Install webinterface
git clone https://github.com/ramondunker/hashcat-azure.git /tmp/hashcat-azure
cp -R /tmp/hashcat-azure/crackerjack /opt/crackerjack
cp /tmp/hashcat-azure/Hashcat-Azure/generate_wordlist.sh /opt/wordlists/generate_wordlist.sh
chmod +x /opt/wordlists/generate_wordlist.sh
chown -R $WEB_USER:$WEB_USER /opt/crackerjack
chmod +x /opt/crackerjack/start.sh
su -p -l $WEB_USER -s $(which bash) -c "cd /opt/crackerjack/ && ./start.sh"
ln -s /opt/crackerjack/crackerjack80.service /etc/systemd/system/crackerjack80.service
ln -s /opt/crackerjack/crackerjack443.service /etc/systemd/system/crackerjack443.service
mkdir /opt/crackerjack/data/config/
mkdir /opt/crackerjack/data/config/http/
cp "/etc/letsencrypt/live/$fqdn/fullchain.pem" /opt/crackerjack/data/config/http/ssl.crt
cp "/etc/letsencrypt/live/$fqdn/privkey.pem" /opt/crackerjack/data/config/http/ssl.pem
mkdir  /var/www/.hashcat
mkdir  /var/www/.hashcat/sessions
chown -R $WEB_USER:$WEB_USER /var/www/.hashcat
chown -R $WEB_USER:$WEB_USER /opt/crackerjack
setcap CAP_NET_BIND_SERVICE=+eip $(readlink -f `which python3`)                          # Gives python3 access to otherwise restricted ports
systemctl enable crackerjack80.service
systemctl enable crackerjack443.service

# Hardening
ufw --force enable
#ufw allow from
ufw allow from 86.94.176.74
#ufw allow to
ufw allow to 86.94.176.74

# Reboot (recommended by CUDA installers and to enable UFW)
reboot
