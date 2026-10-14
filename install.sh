#!/usr/bin/env bash
set -euo pipefail

# Ensure running with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "[-] Error: This script must be run with root privileges (use sudo)."
  echo "    Usage: curl -sL <URL> | sudo bash"
  echo "       or: sudo bash install.sh"
  exit 1
fi

# Determine the non-root desktop user
TARGET_USER="${SUDO_USER:-}"
if [ -z "$TARGET_USER" ] || [ "$TARGET_USER" = "root" ]; then
  TARGET_USER=$(logname 2>/dev/null || who | awk '{print $1}' | head -n 1 || echo "")
fi

if [ -z "$TARGET_USER" ] || [ "$TARGET_USER" = "root" ]; then
  echo "[-] Error: Unable to determine the non-root desktop user."
  echo "    Please run as your regular user with sudo, e.g.: sudo bash install.sh"
  exit 1
fi

TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
TARGET_UID=$(id -u "$TARGET_USER")

echo "=========================================================="
echo " Linux Mint Cinnamon: Fcitx 5 CJK / Hangul Migration Tool"
echo " Target User: $TARGET_USER (Home: $TARGET_HOME)"
echo "=========================================================="

# 1. Purge legacy Fcitx 4 packages
echo "[1/6] Purging legacy Fcitx 4 packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get purge -y fcitx fcitx-bin fcitx-data fcitx-hangul fcitx-config-gtk \
  fcitx-frontend-all fcitx-frontend-gtk2 fcitx-frontend-gtk3 fcitx-frontend-qt5 || true
apt-get autoremove --purge -y

# 2. Update package repositories
echo "[2/6] Updating APT repositories..."
apt-get update

# 3. Install Fcitx 5 stack with frontends and engines
echo "[3/6] Installing Fcitx 5 suite & toolkit frontends..."
apt-get install -y \
  fcitx5 \
  fcitx5-hangul \
  fcitx5-mozc \
  fcitx5-unikey \
  fcitx5-frontend-gtk3 \
  fcitx5-frontend-gtk4 \
  fcitx5-frontend-qt5 \
  fcitx5-frontend-qt6 \
  fcitx5-config-qt

# 4. Configure input framework via im-config
echo "[4/6] Setting active input framework to fcitx5..."
su - "$TARGET_USER" -c "im-config -n fcitx5"

# 5. Pre-configure Fcitx 5 profile for Hangul and English
echo "[5/6] Creating default Fcitx 5 profile and trigger hotkeys..."
FCITX5_CONFIG_DIR="$TARGET_HOME/.config/fcitx5"
mkdir -p "$FCITX5_CONFIG_DIR"

cat << 'EOF' > "$FCITX5_CONFIG_DIR/profile"
[Groups/0]
# Group Name
Name=Default
# Layout
Default Layout=us
# Default Input Method
DefaultIM=keyboard-us

[Groups/0/Items/0]
# Name
Name=keyboard-us
# Layout
Layout=

[Groups/0/Items/1]
# Name
Name=hangul
# Layout
Layout=

[GroupOrder]
0=Default
EOF

cat << 'EOF' > "$FCITX5_CONFIG_DIR/config"
[Hotkey]
EnumerateWithTriggerKeys=True
SkipFirst=False

[Hotkey/TriggerKeys]
0=Hangul
1=Control+space
2=Shift+space
EOF

chown -R "$TARGET_USER:$TARGET_USER" "$FCITX5_CONFIG_DIR"

# 6. Disable Cinnamon/GNOME layout switching shortcut collisions
echo "[6/6] Clearing conflicting desktop layout shortcuts..."
if [ -S "/run/user/$TARGET_UID/bus" ]; then
  sudo -u "$TARGET_USER" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$TARGET_UID/bus" gsettings set org.cinnamon.desktop.keybindings.wm switch-input-source "[]" || true
  sudo -u "$TARGET_USER" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$TARGET_UID/bus" gsettings set org.cinnamon.desktop.keybindings.wm switch-input-source-backward "[]" || true
  sudo -u "$TARGET_USER" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$TARGET_UID/bus" gsettings set org.gnome.desktop.wm.keybindings switch-input-source "[]" || true
  sudo -u "$TARGET_USER" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$TARGET_UID/bus" gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "[]" || true
else
  su - "$TARGET_USER" -c "
    gsettings set org.cinnamon.desktop.keybindings.wm switch-input-source \"[]\" 2>/dev/null || true
    gsettings set org.cinnamon.desktop.keybindings.wm switch-input-source-backward \"[]\" 2>/dev/null || true
    gsettings set org.gnome.desktop.wm.keybindings switch-input-source \"[]\" 2>/dev/null || true
    gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward \"[]\" 2>/dev/null || true
  " || true
fi

echo ""
echo "=========================================================="
echo " [✓] Migration to Fcitx 5 completed successfully!"
echo "=========================================================="
echo " Next step:"
echo "   Please LOG OUT of Cinnamon and LOG BACK IN (or reboot)."
echo ""
echo " After logging in:"
echo "   - Fcitx 5 will start automatically."
echo "   - You can toggle Hangul with the Hangul key, Ctrl+Space,"
echo "     or Shift+Space directly inside the Cinnamon menu search."
echo "=========================================================="
