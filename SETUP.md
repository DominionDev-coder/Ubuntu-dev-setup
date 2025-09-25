# Fedora SSD DevKit Post-Installation Guide

## 1. Anaconda & AI Environment
- Activate AI environment:
  ```bash
  conda activate ai
  ```
- Deactivate:
  ```bash
  conda deactivate
  ```
- Update packages:
  ```bash
  conda update --all -n ai
  ```

## 2. Docker Development
- Start Docker service:
  ```bash
  sudo systemctl start docker
  ```
- Run databases:
  ```bash
  docker run -d --name pg -e POSTGRES_PASSWORD=dev -p 5432:5432 postgres
  docker run -d --name mongo -p 27017:27017 mongo
  docker run -d --name redis -p 6379:6379 redis
  ```

## 3. Tunneling (expose localhost)
- Ngrok:
  ```bash
  ngrok http 8000
  ```
- LocalTunnel:
  ```bash
  lt --port 8000
  ```

## 4. Updating Tools
- Fedora system:
  ```bash
  sudo dnf upgrade --refresh
  ```
- Node.js packages:
  ```bash
  npm update -g
  ```
- Python (system):
  ```bash
  pip install --upgrade pip setuptools wheel
  ```

## 5. Networking & Drivers
- Manage Wi-Fi: use **network manager applet** in tray.  
- Bluetooth manager: run `blueman-manager`.  
- Broadcom Wi-Fi: handled by `broadcom-wl`.  

## 6. Notes
- Swap: Fedora auto-manages a swapfile; no manual setup needed.  
- Pulumi is installed in `$HOME/.pulumi/bin`.  
- Warp installed via Flatpak: launch via menu or `warp`.  

---
✨ This Fedora SSD DevKit is optimized for:  
- General software development (Python, Java, Node.js, Dart/Flutter, Go, Rust, .NET)  
- AI/ML/Data science (Anaconda environment `ai`)  
- Cloud & DevOps (Docker, Pulumi, tunneling tools)  
- Git & collaboration (GitHub Desktop, GitKraken, Warp)  
