#!/usr/bin/env bash
# =====================================================
# Linux Mint DevKit Setup Script
# Target: External SSD-based Dev OS
# =====================================================
# Run inside Linux Mint (on SSD):
# chmod +x setup_devkit.sh && ./setup_devkit.sh
# =====================================================

set -e

echo "🚀 Starting DevKit setup..."

# ----------------------------
# Update system
# ----------------------------
sudo apt update && sudo apt -y upgrade
sudo apt -y install software-properties-common apt-transport-https curl wget git unzip build-essential gnupg lsb-release ca-certificates htop net-tools ufw

# ----------------------------
# Broadcom Wi-Fi (for MacBook Air 6,1)
# ----------------------------
echo "📶 Installing Broadcom Wi-Fi driver..."
sudo apt -y install bcmwl-kernel-source

# ----------------------------
# Bluetooth tethering tools
# ----------------------------
echo "🔵 Installing Bluetooth utilities..."
sudo apt -y install blueman bluez bluez-tools rfkill

# ----------------------------
# Expand Swapfile to 8GB
# ----------------------------
echo "⚡ Configuring swapfile..."
sudo swapoff -a || true
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# ----------------------------
# Python & AI Dev
# ----------------------------
sudo apt -y install python3 python3-pip python3-venv python3-dev jupyter-notebook
# Anaconda
wget https://repo.anaconda.com/archive/Anaconda3-2024.06-1-Linux-x86_64.sh -O ~/anaconda.sh
bash ~/anaconda.sh -b -p $HOME/anaconda3
echo 'export PATH="$HOME/anaconda3/bin:$PATH"' >> ~/.bashrc
rm ~/anaconda.sh
# Popular AI libs
pip install --upgrade pip
pip install torch torchvision torchaudio tensorflow scikit-learn pandas numpy matplotlib seaborn kaggle

# ----------------------------
# Node.js, npm, TypeScript
# ----------------------------
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt -y install nodejs
sudo npm install -g typescript yarn

# ----------------------------
# Dart & Flutter
# ----------------------------
sudo apt -y install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
git clone https://github.com/flutter/flutter.git -b stable ~/flutter
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc

# ----------------------------
# Pulumi
# ----------------------------
curl -fsSL https://get.pulumi.com | sh
echo 'export PATH="$HOME/.pulumi/bin:$PATH"' >> ~/.bashrc

# ----------------------------
# Windsurf IDE
# ----------------------------
wget https://windsurf.dev/linux/windsurf_latest_amd64.deb -O ~/windsurf.deb
sudo dpkg -i ~/windsurf.deb || sudo apt -f install -y
rm ~/windsurf.deb

# ----------------------------
# Tunneling tools (ngrok & localtunnel)
# ----------------------------
wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip -O ~/ngrok.zip
unzip ~/ngrok.zip -d ~/ && sudo mv ~/ngrok /usr/local/bin/ && rm ~/ngrok.zip
sudo npm install -g localtunnel

# ----------------------------
# Networking optimizers
# ----------------------------
sudo apt -y install iperf3 traceroute nethogs

# ----------------------------
# Security tools
# ----------------------------
sudo apt -y install fail2ban gufw clamav clamav-daemon

# ----------------------------
# Packaging tools
# ----------------------------
sudo apt -y install rpm alien dpkg-dev fakeroot lintian

# ----------------------------
# Cleanup
# ----------------------------
sudo apt -y autoremove
sudo apt -y clean

echo "✅ DevKit setup complete! Restart your terminal or reboot to load changes."
