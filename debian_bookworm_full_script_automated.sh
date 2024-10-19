#!/bin/bash
# Automation script for Raspberry Pi 4B (Debian Bookworm)
# Script will exit on any error
set -e

# Step 1: Removing pre-installed software
sudo apt-get remove geany vlc thonny dillo bluez bluez-firmware libbluetooth3 -y
sudo apt autoremove -y

# Step 2: Installing necessary apps
sudo apt-get update
sudo apt-get install network-manager qbittorrent gsmartcontrol vnstat ufw apt-transport-https curl gnome-tweaks papirus-icon-theme -y
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
sudo apt-get install speedtest -y

# Step 3: Installing Plex Media Server
curl https://downloads.plex.tv/plex-keys/PlexSign.key | gpg --dearmor | sudo tee /usr/share/keyrings/plex-archive-keyring.gpg >/dev/null
echo deb [signed-by=/usr/share/keyrings/plex-archive-keyring.gpg] https://downloads.plex.tv/repo/deb public main | sudo tee /etc/apt/sources.list.d/plexmediaserver.list
sudo apt-get update
sudo apt install plexmediaserver -y

# Step 3.1: Give Plex Storage (HDD) permission to read and write
sudo usermod -a -G pi plex
sudo chown pi:plex /media/pi
sudo chmod 750 /media/pi
sudo setfacl -m g:plex:rwx /media/pi
sudo service plexmediaserver restart

# Step 4: Allowing ports for Plex and qBittorrent
sudo ufw allow 32400
sudo ufw allow 62758

# Optional 1.1: Customization (Fonts and Icons)
# qt5ct > Fusion - Default | Default
# Icon themes - Papirus-dark

# Network optimization for 1Gb/s connection
sudo fallocate -l 6G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
sudo swapon --show
free -h

# Set maximum number of open files
echo "Setting maximum number of open files..."
echo "fs.file-max = 200000" | sudo tee -a /etc/sysctl.conf
echo "ulimit -n 200000" >> ~/.bashrc

# TCP Congestion Protocol (BBR)
echo "net.core.default_qdisc = fq" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control = bbr" | sudo tee -a /etc/sysctl.conf

# TCP Optimizations for high-speed connections
echo "net.core.rmem_max = 16777216" | sudo tee -a /etc/sysctl.conf
echo "net.core.wmem_max = 16777216" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_rmem = 4096 87380 16777216" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_wmem = 4096 65536 16777216" | sudo tee -a /etc/sysctl.conf

# Additional TCP settings for optimization
echo "net.ipv4.tcp_window_scaling = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_sack = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_no_metrics_save = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_syn_retries = 2" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_retries2 = 2" | sudo tee -a /etc/sysctl.conf

# Enable server-side TCP optimizations
echo "Enabling TCP Fast Open..."
echo "net.ipv4.tcp_fastopen = 3" | sudo tee -a /etc/sysctl.conf

# Apply the TCP settings
sudo sysctl -p

# Optional 1.3: Overclocking Raspberry Pi 4B
# Overclocking Pi at 2GHz.
if [ -f /boot/config.txt ]; then
    sudo sed -i '/^over_voltage=/d' /boot/config.txt
    sudo sed -i '/^arm_freq=/d' /boot/config.txt
    sudo sed -i '/^gpu_mem=/d' /boot/config.txt

    echo "over_voltage=6" | sudo tee -a /boot/config.txt
    echo "arm_freq=2000" | sudo tee -a /boot/config.txt
    echo "gpu_mem=256" | sudo tee -a /boot/config.txt
fi

if [ -f /boot/firmware/config.txt ]; then
    sudo sed -i '/^over_voltage=/d' /boot/firmware/config.txt
    sudo sed -i '/^arm_freq=/d' /boot/firmware/config.txt
    sudo sed -i '/^gpu_mem=/d' /boot/firmware/config.txt

    echo "over_voltage=6" | sudo tee -a /boot/firmware/config.txt
    echo "arm_freq=2000" | sudo tee -a /boot/firmware/config.txt
    echo "gpu_mem=256" | sudo tee -a /boot/firmware/config.txt
fi
