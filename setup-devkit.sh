#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Starting DevKit full-setup..."

# --- Update & base utilities ---
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
  build-essential curl wget git unzip zip tar software-properties-common \
  apt-transport-https ca-certificates gnupg lsb-release \
  tmux zsh fish fzf ripgrep broot ncdu duf tree jq htop net-tools

# --- Handle Wi-Fi Broadcom driver (if needed) ---
sudo apt install -y bcmwl-kernel-source || true

# --- Python / AI / Data Science stack ---
sudo apt install -y python3 python3-pip python3-venv python3-dev
python3 -m pip install --upgrade pip setuptools wheel

python3 -m pip install \
  numpy pandas scipy scikit-learn jupyterlab matplotlib seaborn \
  torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu \
  tensorflow keras fastai transformers datasets \
  mlflow onnx onnxruntime kaggle

# --- Node.js / TypeScript / Web dev ---
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g npm typescript eslint prettier

# --- Dart SDK ---
sudo apt update
sudo apt install -y apt-transport-https
wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor > dart.gpg
sudo mv dart.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
sudo apt update
sudo apt install -y dart

# --- DevOps / Infrastructure Tools ---
sudo apt install -y ansible apache-jmeter locust packer
VAULT_VERSION="1.17.0"
curl -fsSL https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -o vault.zip
unzip vault.zip
sudo mv vault /usr/local/bin/
rm vault.zip
curl -sS https://webinstall.dev/k9s | bash
curl -fsSL https://get.pulumi.com | sh

# --- Security / Code Quality ---
curl -sL https://snyk.io/install.sh | bash
sudo snap install zaproxy --classic

# --- Networking / Connectivity Tools ---
sudo apt install -y bmon traceroute netcat-openbsd iperf3 ethtool mtr speedtest-cli wondershaper wireguard
sudo apt install -y cargo
cargo install bandwhich

# --- Database Clients ---
sudo apt install -y sqlite3 postgresql-client mysql-client redis-tools mongodb-clients

# --- Editors / IDEs ---
sudo snap install code --classic
wget https://windsurf.com/download/editor/linux/windsurf-latest.deb -O windsurf.deb
sudo apt install -y ./windsurf.deb
rm windsurf.deb

# --- Backup & Sync ---
sudo apt install -y restic borgbackup rclone

# --- Packaging Tools ---
sudo apt install -y dpkg-dev rpm flatpak
wget https://github.com/AppImage/AppImageKit/releases/latest/download/appimagetool-x86_64.AppImage -O appimagetool
chmod +x appimagetool
sudo mv appimagetool /usr/local/bin/

# --- Swapfile resize (2GB -> 8GB) ---
echo "🔧 Resizing swapfile to 8GB..."
sudo swapoff -a || true
sudo rm /swapfile || true
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
if ! grep -q "/swapfile" /etc/fstab; then
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi

# --- Shared Partition ---
SHARED_DEV=$(lsblk -o NAME,FSTYPE,LABEL,SIZE,MOUNTPOINT | grep SHARED | awk '{print $1}')
if [ -n "$SHARED_DEV" ]; then
  echo "Formatting and mounting shared partition $SHARED_DEV as exFAT..."
  sudo apt install -y exfat-fuse exfatprogs
  sudo mkfs.exfat -n SHARED /dev/$SHARED_DEV
  sudo mkdir -p /mnt/SHARED
  echo "/dev/$SHARED_DEV /mnt/SHARED exfat defaults,noatime,uid=$(id -u),gid=$(id -g),umask=002 0 0" | sudo tee -a /etc/fstab
  sudo mount -a
else
  echo "⚠️ Shared partition not found — skipping."
fi

sudo apt autoremove -y
sudo apt clean

echo "✅ DevKit setup finished!"
echo "➡️ Please reboot your system."
