# Parrot OS SSD DevKit — Post-Installation Guide (Updated)

This document explains what `parrot_setup.sh` does and how to use the environments, desktop customization, drivers, and tips.

## Quick Start
1. Make script executable and run it:
   ```bash
   chmod +x parrot_setup.sh
   ./parrot_setup.sh
   ```
2. Reboot when complete:
   ```bash
   sudo reboot
   ```

## Environments (activation / deactivation)
- **Development environment** (default tools available after activation):
  - Activate: `source ~/bin/activate-dev`
  - Deactivate: `source ~/bin/deactivate-dev`
- **Pentest environment** (tools isolated under `/opt/pentest`):
  - Activate: `source ~/bin/activate-pentest`
  - Deactivate: `source ~/bin/deactivate-pentest`

The activation scripts only modify the current shell's environment (PATH). Opening a new terminal resets environment to system defaults.

## Desktop customization
- The script installs **Plank** (lightweight dock) and sets it to autostart.
- Installs KDE helper tools (kvantum theme engine, breeze icon themes, plasma widgets). You can change themes via System Settings → Appearance.
- Attempts to set a default wallpaper (uses a placeholder image). KDE-specific customization that requires a running X/Plasma session may not apply from an SSH session; log into KDE and verify appearance settings.

## Drivers
- **Broadcom Wi‑Fi:** The script installs `broadcom-sta-dkms` and `bcmwl` packages where available. If Wi‑Fi fails after install, use USB tethering or ethernet to fetch drivers, and check `sudo dkms status`. Secure Boot may prevent unsigned modules from loading.
- **GPU / Video:** Installs Mesa, VA drivers, and Vulkan utilities for Intel GPUs. This should enable hardware acceleration where supported.
- **FaceTime HD camera:** **NOT installed** — user requested to skip it to avoid macOS dependencies.

## Anaconda & AI
- Anaconda installed to `~/anaconda3` (does not auto-activate on shell start).
- AI conda env named `ai` created. Activate with `conda activate ai`.
- Manage conda with normal conda commands:
  ```bash
  conda update conda
  conda update --all -n ai
  ```

## Pentesting tools isolation
- Pentest binaries are left in system locations but the script registers them by symlink into `/opt/pentest/bin` (so they are not in PATH by default).
- Activate the pentest environment to prepend `/opt/pentest/bin` to your PATH and access the tools.

## Docker & Databases
- Docker is installed and enabled. The script pre-pulled common images (postgres, mongo, redis). Use Docker to run DB instances, for example:
  ```bash
  docker run -d --name pg -e POSTGRES_PASSWORD=dev -p 5432:5432 postgres
  ```

## Swap & SSD
- Script creates an 8GB swapfile at `/swapfile`. Verify with:
  ```bash
  swapon --show
  free -h
  ```
- `fstrim.timer` is enabled for SSD health.

## Safety & cleanup
- Pentesting tools are powerful — only use them legally and ethically.
- If you want stronger isolation, consider running pentest tools inside Docker containers or a VM; I can generate a docker-compose that includes these tools.

## Troubleshooting tips
- If Broadcom Wi‑Fi fails: `sudo dkms status`, `sudo modprobe wl`, check `dmesg` for module errors.
- If GPU acceleration not working: run `vainfo` and `glxinfo | grep OpenGL` (install `mesa-utils`).
- Reboot after major installs and after adding user to `docker` group.
- To free space: `sudo apt autoremove`, `docker image prune -a`, remove unused conda envs: `conda env remove -n ai`.

## Files included
- `parrot_setup.sh` — this script.
- `PARROT_SETUP.md` — this doc.

If you want I can:
1. Convert pentest tools to Docker images and provide docker-compose files to run them on demand.  
2. Add richer KDE desktop theming (Latte Dock, specific theme setup) — Latte may require additional repos.  
3. Make the script interactive (prompt which optional tool groups to install).
---
