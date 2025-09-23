#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Starting full DevKit setup..."

# ---------- Update & Base Tools ----------
sudo apt update && sudo apt upgrade -y
sudo apt install -y     build-essential curl wget git unzip zip tar software-properties-common     apt-transport-https ca-certificates gnupg lsb-release     tmux zsh fish fzf ripgrep broot ncdu duf tree jq htop net-tools

# ---------- Python + AI / Data Science Stack ----------
sudo apt install -y python3 python3-pip python3-venv python3-dev
python3 -m pip install --upgrade pip setuptools wheel

python3 -m pip install     numpy pandas scipy scikit-learn jupyterlab matplotlib seaborn     torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu     tensorflow keras fastai transformers datasets     mlflow onnx onnxruntime kaggle

# ---------- Node.js / TypeScript / Web Dev ----------
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g npm typescript eslint prettier

# ---------- Dart SDK ----------
sudo apt update
sudo apt install -y apt-transport-https
wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor > dart.gpg
sudo mv dart.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
sudo apt update
sudo apt install -y dart

# ---------- DevOps / Infrastructure ----------
sudo apt install -y ansible apache-jmeter locust packer

# Vault
VAULT_VERSION="1.17.0"
curl -fsSL https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -o vault.zip
unzip vault.zip
sudo mv vault /usr/local/bin/
rm vault.zip

# k9s
curl -sS https://webinstall.dev/k9s | bash

# Pulumi
curl -fsSL https://get.pulumi.com | sh

# ---------- Security / Code Quality ----------
curl -sL https://snyk.io/install.sh | bash
sudo snap install zaproxy --classic
# SonarLint is an IDE plugin, so install via IDE when needed

# ---------- Networking / Connectivity Optimizers ----------
sudo apt install -y bmon traceroute netcat-openbsd iperf3 ethtool mtr speedtest-cli wondershaper wireguard
sudo apt install -y cargo
cargo install bandwhich

# ---------- Database Clients ----------
sudo apt install -y sqlite3 postgresql-client mysql-client redis-tools mongodb-clients

# ---------- Editors / IDEs ----------
sudo snap install code --classic
# Windsurf (official Linux version)
wget https://windsurf.com/download/editor/linux/windsurf-latest.deb -O windsurf.deb
sudo apt install -y ./windsurf.deb
rm windsurf.deb

# ---------- Backup & Sync Tools ----------
sudo apt install -y restic borgbackup rclone

# ---------- Packaging Tools ----------
sudo apt install -y dpkg-dev rpm flatpak
wget https://github.com/AppImage/AppImageKit/releases/latest/download/appimagetool-x86_64.AppImage -O appimagetool
chmod +x appimagetool
sudo mv appimagetool /usr/local/bin/

# ---------- Shared exFAT Partition (50 GB) ----------
SHARE_PARTITION="/dev/sda3"   # adjust if device differs
sudo apt install -y exfat-fuse exfatprogs
sudo mkdir -p /mnt/SHARED
echo "${SHARE_PARTITION} /mnt/SHARED exfat defaults,noatime,uid=$(id -u),gid=$(id -g),umask=002 0 0" | sudo tee -a /etc/fstab
sudo mount -a

# ---------- Cleanup & Optimization ----------
sudo apt autoremove -y
sudo apt clean

echo "✅ DevKit setup completed!"
echo "➡️ Please reboot your system."
echo "➡️ Shared folder should be mounted at /mnt/SHARED"
