# 🚀 Post-Installation Guide: Linux Mint DevKit on SSD

After you have installed Linux Mint onto your SSD and completed the basic setup (username, password, language, etc.), follow these steps to prepare your DevKit system.

---

## 1. First Boot
1. Boot into your SSD (hold **Option ⌥** on Mac and choose the SSD).
2. Log in to Linux Mint.
3. Connect to Wi-Fi or Ethernet.

---

## 2. Run the Setup Script
1. Copy `setup_devkit.sh` into your Linux Mint home folder.  
   - If you uploaded it to GitHub:  
     ```bash
     git clone <your-repo-url>
     cd <repo>
     ```
   - Or copy from USB.

2. Make it executable and run:
   ```bash
   chmod +x setup_devkit.sh
   ./setup_devkit.sh
   ```

---

## 3. What the Script Does
- Expands swapfile to **8GB**
- Installs dev tools:
  - **Python** + pip, venv, Jupyter
  - **Anaconda** (with data science & AI libs: PyTorch, TensorFlow, scikit-learn, Pandas, Kaggle, etc.)
  - **Node.js, npm, TypeScript, Yarn**
  - **Dart & Flutter**
  - **Pulumi**
  - **Windsurf IDE**
  - **Tunneling tools**: ngrok, localtunnel
  - **Networking tools**: iperf3, traceroute, nethogs
  - **Security tools**: ufw, fail2ban, ClamAV
  - **Packaging tools**: rpm, alien, dpkg-dev, fakeroot, lintian
- Cleans unused packages

---

## 4. Verify Installation
Check tools after setup:

```bash
python3 --version
conda --version
node -v
tsc -v
flutter doctor
pulumi version
ngrok version
```

---

## 5. Maintenance
- Update your system regularly:
  ```bash
  sudo apt update && sudo apt upgrade -y
  ```
- Clean junk:
  ```bash
  sudo apt autoremove && sudo apt clean
  ```

---

## ✅ Your SSD is now a portable, full-featured DevKit OS.
