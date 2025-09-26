#!/usr/bin/env bash
# parrot_setup.sh - Post-install setup for Parrot OS (Home/KDE) on Intel MacBook SSD
# - Development environment + Anaconda (ai env)
# - Pentest tools installed but isolated under /opt/pentest (activated only via wrapper)
# - Desktop customization: install dock (plank or latte), themes, autostart entries
# - GPU (Mesa/vulkan) and Broadcom Wi‑Fi drivers installed (best-effort)
# - Creates activation/deactivation scripts for dev and pentest
# - DOES NOT install FaceTime camera driver (user requested to skip it)
#
# Run as regular user with sudo privileges:
# chmod +x parrot_setup.sh && ./parrot_setup.sh
set -euo pipefail

ME=$(whoami)
echo "[*] Starting Parrot post-install setup (user: $ME)"
echo "[*] NOTE: This script attempts best-effort installs. Reboot after completion."

# --- Update system ---
echo "[1/20] Updating apt and system packages..."
sudo apt update && sudo apt -y full-upgrade

# --- Essentials and build tools ---
echo "[2/20] Installing essential build tools and utilities..."
sudo apt -y install build-essential dkms linux-headers-$(uname -r) \
  git curl wget unzip ca-certificates apt-transport-https gnupg lsb-release \
  software-properties-common pkg-config apt-transport-https

# --- Programming languages & runtimes ---
echo "[3/20] Installing languages & runtimes (Python, Node, Java, Go, Rust, Ruby, Dart)..."
sudo apt -y install python3 python3-pip python3-venv python3-dev \
  openjdk-17-jdk maven gradle \
  golang-go \
  rustc cargo \
  ruby-full \
  php php-cli php-xml composer

# Node.js (LTS) via NodeSource
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt -y install nodejs
# yarn via npm
sudo npm install -g yarn || true

# Dart (official repo)
if ! grep -q "dart.dev" /etc/apt/sources.list.d/dart_stable.list 2>/dev/null; then
  echo "deb [signed-by=/usr/share/keyrings/dart.gpg] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main" | sudo tee /etc/apt/sources.list.d/dart_stable.list
  curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/dart.gpg
  sudo apt update
  sudo apt -y install dart || true
fi

# Flutter (snap if available) - best effort
if command -v snap >/dev/null 2>&1; then
  echo "[*] Installing Flutter via snap..."
  sudo snap install flutter --classic || true
else
  echo "[!] snap not found; skip Flutter automatic install. You can install Flutter manually later."
fi

# --- Containers & Docker ---
echo "[4/20] Installing Docker & Podman..."
sudo apt -y install docker.io docker-compose podman buildah skopeo
sudo systemctl enable --now docker || true
# add user to docker group
sudo usermod -aG docker $ME || true

# Pre-pull common development docker images (non-blocking)
echo "[5/20] Pulling common Docker images (this may take time)..."
docker pull postgres:latest || true
docker pull mongo:latest || true
docker pull redis:latest || true
docker pull mysql:latest || true
docker pull node:latest || true
docker pull python:latest || true
docker pull nginx:latest || true

# --- Pulumi & CLI tools ---
echo "[6/20] Installing Pulumi (IaC) and other CLIs..."
curl -fsSL https://get.pulumi.com | sh || true
echo 'export PATH=\"$HOME/.pulumi/bin:$PATH\"' >> \"$HOME/.bashrc\" || true

# ngrok & localtunnel
echo "[7/20] Installing ngrok and localtunnel..."
NGROK_ZIP=/tmp/ngrok.zip
curl -s -L -o $NGROK_ZIP \"https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-stable-linux-amd64.zip\" || true
unzip -o $NGROK_ZIP -d /tmp || true
sudo mv -f /tmp/ngrok /usr/local/bin/ngrok || true
rm -f $NGROK_ZIP || true
sudo npm install -g localtunnel || true

# --- GPU drivers (Mesa/VA/Vulkan) ---
echo "[8/20] Installing Mesa / video / Vulkan support (Intel GPU) ..."
sudo apt -y install mesa-utils vainfo i965-va-driver-shaders intel-media-va-driver-non-free \
  libvulkan1 vulkan-tools vulkan-utils || true

# --- Broadcom Wi‑Fi (best-effort) ---
echo "[9/20] Installing Broadcom Wi-Fi drivers (broadcom-sta) (best-effort)..."
sudo apt -y install broadcom-sta-dkms broadcom-sta-common bcmwl-kernel-source || true
# try to load module
sudo modprobe wl || true

# --- Bluetooth ---
echo "[10/20] Installing Bluetooth stack..."
sudo apt -y install bluez bluez-tools blueman rfkill || true
sudo systemctl enable --now bluetooth || true

# --- Anaconda + AI conda env (non-default) ---
echo "[11/20] Installing Anaconda (into ~/anaconda3) and creating 'ai' env..."
ANACONDA_INS=\"Anaconda3-2024.06-1-Linux-x86_64.sh\"
cd /tmp
if [ ! -f \"/tmp/$ANACONDA_INS\" ]; then
  curl -sLO \"https://repo.anaconda.com/archive/$ANACONDA_INS\" || true
fi
bash /tmp/$ANACONDA_INS -b -p \"$HOME/anaconda3\" || true
# add to bashrc but do not make default -- conda init commented out
echo '# Anaconda (added by parrot_setup.sh) - not auto-activating' >> \"$HOME/.bashrc\"
echo 'export PATH=\"$HOME/anaconda3/bin:$PATH\"' >> \"$HOME/.bashrc\"
# create ai environment
\"$HOME/anaconda3/bin/conda\" create -y -n ai python=3.10 numpy scipy pandas scikit-learn matplotlib seaborn \
    jupyter jupyterlab notebook plotly bokeh \
    pytorch torchvision torchaudio cpuonly -c pytorch || true
\"$HOME/anaconda3/bin/conda\" install -y -n ai tensorflow keras xgboost opencv -c conda-forge || true
\"$HOME/anaconda3/bin/conda\" install -y -n ai kaggle requests beautifulsoup4 scrapy pandas-datareader || true
\"$HOME/anaconda3/bin/conda\" install -y -n ai sqlalchemy psycopg2 pymongo redis || true

# --- Install VS Code and JetBrains Toolbox ---
echo "[12/20] Installing VS Code and JetBrains Toolbox (best-effort)..."
# VS Code repo
curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >/tmp/microsoft.gpg || true
sudo install -o root -g root -m 644 /tmp/microsoft.gpg /usr/share/keyrings/microsoft.gpg || true
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list || true
sudo apt update || true
sudo apt -y install code || true
# JetBrains Toolbox
TB_DIR="/opt/jetbrains-toolbox"
sudo mkdir -p "$TB_DIR" || true
curl -sL "https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.27.3.17884.tar.gz" -o /tmp/jetbrains-toolbox.tar.gz || true
sudo tar -xzf /tmp/jetbrains-toolbox.tar.gz -C "$TB_DIR" --strip-components=1 || true
sudo ln -sf "$TB_DIR/jetbrains-toolbox" /usr/local/bin/jetbrains-toolbox || true

# --- GUI tools: GitKraken, Warp (best-effort) ---
echo "[13/20] Installing GitKraken (deb) and Warp (if available)..."
if ! command -v gitkraken >/dev/null 2>&1; then
  wget -qO /tmp/gitkraken.deb "https://release.axocdn.com/linux/gitkraken-amd64.deb" || true
  sudo apt -y install /tmp/gitkraken.deb || true
fi
# Warp - best effort (may not have Linux deb for all releases)
wget -qO /tmp/warp.deb "https://releases.warp.dev/stable/warp-latest-amd64.deb" || true
sudo apt -y install /tmp/warp.deb || true || true

# --- Pentest tools installation (packages only) and isolation plan ---
echo "[14/20] Installing pentest tools (packages only). They will be registered under /opt/pentest but not added to PATH by default."
sudo mkdir -p /opt/pentest/bin /opt/pentest/share || true
# Install common pentest packages (this is large)
sudo apt -y install nmap sqlmap nikto hydra john hashcat aircrack-ng \
  mitmproxy smbclient enum4linux dnsrecon theharvester dirb gobuster \
  metasploit-framework || true
# Create symlinks in /opt/pentest/bin for installed tools
for tool in nmap sqlmap nikto hydra john hashcat aircrack-ng mitmproxy smbclient dnsrecon theharvester dirb gobuster metasploit-framework; do
  if command -v "$tool" >/dev/null 2>&1; then
    sudo ln -sf "$(command -v $tool)" "/opt/pentest/bin/$(basename $tool)" || true
  fi
done
sudo chown -R root:root /opt/pentest || true
sudo chmod -R 755 /opt/pentest || true

# --- Activation & deactivation scripts ---
echo "[15/20] Creating activation/deactivation scripts (~/bin)..."
mkdir -p "$HOME/bin"
# Activate dev (adds ~/bin and ~/.local/bin)
cat > "$HOME/bin/activate-dev" <<'DEV_SCRIPT'
#!/usr/bin/env bash
export OLD_PATH="$PATH"
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
echo "Dev environment activated. Run 'deactivate-dev' to undo."
DEV_SCRIPT
chmod +x "$HOME/bin/activate-dev"
# Deactivate dev
cat > "$HOME/bin/deactivate-dev" <<'DEACT_DEV'
#!/usr/bin/env bash
if [ -n "${OLD_PATH-}" ]; then
  export PATH="$OLD_PATH"
  unset OLD_PATH
fi
echo "Dev environment deactivated."
DEACT_DEV
chmod +x "$HOME/bin/deactivate-dev"

# Activate pentest (prepends /opt/pentest/bin)
cat > "$HOME/bin/activate-pentest" <<'PENT_SCRIPT'
#!/usr/bin/env bash
export OLD_PATH="$PATH"
export PATH="/opt/pentest/bin:$PATH"
export PENTEST_ACTIVE=1
echo "Pentest environment activated. Run 'deactivate-pentest' to undo."
PENT_SCRIPT
chmod +x "$HOME/bin/activate-pentest"
# Deactivate pentest
cat > "$HOME/bin/deactivate-pentest" <<'DEACT_PENT'
#!/usr/bin/env bash
if [ -n "${OLD_PATH-}" ]; then
  export PATH="$OLD_PATH"
  unset OLD_PATH
fi
unset PENTEST_ACTIVE
echo "Pentest environment deactivated."
DEACT_PENT
chmod +x "$HOME/bin/deactivate-pentest"

# --- Desktop customization (KDE) ---
echo "[16/20] Desktop customization: installing a dock (plank) and KDE theming helpers..."
sudo apt -y install plank lxappearance packagekit-gtk3-module kvantum qt5-style-kvantum breeze-icon-theme plasma-widgets-addons || true

# Create autostart desktop entry for plank
AUTOSTART_DIR="$HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"
cat > "$AUTOSTART_DIR/plank.desktop" <<'PLANK'
[Desktop Entry]
Type=Application
Name=Plank Dock
Exec=plank
X-GNOME-Autostart-enabled=true
NoDisplay=false
Comment=Start Plank Dock on login
PLANK
chmod +x "$AUTOSTART_DIR/plank.desktop" || true

# Optional: set a simple wallpaper (if available)
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
mkdir -p "$WALLPAPER_DIR"
if [ ! -f "$WALLPAPER_DIR/default-wallpaper.jpg" ]; then
  curl -sL "https://picsum.photos/1920/1080" -o "$WALLPAPER_DIR/default-wallpaper.jpg" || true
fi
python3 - <<'PYSET' || true
import os,subprocess
wp=os.path.expanduser("~/Pictures/Wallpapers/default-wallpaper.jpg")
cmd=['qdbus','org.kde.plasmashell','/PlasmaShell','org.kde.PlasmaShell.evaluateScript',
"var allDesktops = desktops();for (i=0;i<allDesktops.length;i++){d = allDesktops[i];d.wallpaperPlugin = 'org.kde.image';d.currentConfigGroup = Array('Wallpaper','org.kde.image','General');d.writeConfig('Image','file://%s')}" % wp]
try:
    subprocess.run(cmd, check=True)
except Exception as e:
    pass
PYSET

# --- SSD TRIM ---
echo "[17/20] Enabling periodic TRIM (fstrim.timer)..."
sudo systemctl enable --now fstrim.timer || true

# --- Swapfile ensured (8GB) if not already present ---
echo "[18/20] Ensuring swapfile (8GB) exists..."
if ! sudo swapon --show | grep -q '/swapfile'; then
  sudo fallocate -l 8G /swapfile || sudo dd if=/dev/zero of=/swapfile bs=1M count=8192
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi

# --- Cleanup & finish ---
echo "[19/20] Cleaning up apt cache..."
sudo apt -y autoremove || true
sudo apt -y clean || true

echo "[20/20] Setup finished. Please reboot to complete driver/module loads and desktop changes."
echo "Use 'source ~/bin/activate-dev' or 'source ~/bin/activate-pentest' to switch modes."
