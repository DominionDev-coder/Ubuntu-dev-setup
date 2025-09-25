#!/usr/bin/env bash
set -e

echo "[*] Updating Fedora system..."
sudo dnf -y upgrade --refresh

echo "[*] Installing essential build tools and utilities..."
sudo dnf -y groupinstall "Development Tools"
sudo dnf -y install curl wget git unzip zip tar make cmake gcc gcc-c++ nano vim htop btop net-tools

echo "[*] Installing programming languages and runtimes..."
sudo dnf -y install python3 python3-pip python3-venv     java-17-openjdk java-17-openjdk-devel     nodejs npm golang ruby rust cargo dart     dotnet-sdk-8.0

echo "[*] Installing Docker & enabling service..."
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

echo "[*] Pulling common Docker images..."
docker pull postgres
docker pull mongo
docker pull redis
docker pull mysql
docker pull node
docker pull python
docker pull nginx
docker pull busybox

echo "[*] Installing developer tools (IDEs, Git, cloud tools)..."
sudo dnf -y install gitkraken gh git-extras
# Warp terminal (flatpak)
flatpak install -y flathub dev.warp.Warp

echo "[*] Installing Flutter/Dart SDK..."
sudo dnf -y install flutter dart

echo "[*] Installing Pulumi (IaC tool)..."
curl -fsSL https://get.pulumi.com | sh
echo 'export PATH="$HOME/.pulumi/bin:$PATH"' >> ~/.bashrc

echo "[*] Installing tunneling tools (ngrok, localtunnel)..."
curl -s https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip -o ngrok.zip
unzip -o ngrok.zip && sudo mv ngrok /usr/local/bin && rm ngrok.zip
npm install -g localtunnel

echo "[*] Installing networking optimization tools..."
sudo dnf -y install iperf3 traceroute network-manager-applet

echo "[*] Installing Broadcom Wi-Fi drivers (if needed)..."
sudo dnf -y install broadcom-wl kernel-devel kernel-headers

echo "[*] Installing Bluetooth stack..."
sudo dnf -y install bluez bluez-tools blueman

echo "[*] Installing Anaconda for AI/Data Science..."
cd /tmp
curl -O https://repo.anaconda.com/archive/Anaconda3-2024.06-1-Linux-x86_64.sh
bash Anaconda3-2024.06-1-Linux-x86_64.sh -b -p $HOME/anaconda3
echo 'export PATH="$HOME/anaconda3/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

echo "[*] Creating AI environment in Anaconda..."
conda create -y -n ai python=3.10 numpy scipy pandas scikit-learn matplotlib seaborn     jupyter jupyterlab notebook plotly bokeh     pytorch torchvision torchaudio cpuonly -c pytorch     tensorflow keras xgboost opencv -c conda-forge     kaggle requests beautifulsoup4 scrapy newspaper3k pandas-datareader     sqlalchemy psycopg2 pymongo redis weaviate-client chromadb faiss-cpu sqlite-utils

echo "[*] Setup completed. Restart your system to finalize."
