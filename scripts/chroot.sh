#!/usr/bin/env bash
# scripts/chroot.sh — runs INSIDE arch-chroot
# Expects config.sh to be present alongside this script, and
# ROOT_PASS / USER_PASS to be set as environment variables.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"

: "${ROOT_PASS:?ROOT_PASS not set}"
: "${USER_PASS:?USER_PASS not set}"

echo "[chroot] Setting timezone..."
ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
hwclock --systohc

echo "[chroot] Setting locale..."
sed -i "s/^#${LOCALE}/${LOCALE}/" /etc/locale.gen
locale-gen
sed "s/__LOCALE__/${LOCALE}/" "$SCRIPT_DIR/../files/locale.conf" > /etc/locale.conf

echo "[chroot] Setting hostname..."
echo "${HOSTNAME}" > /etc/hostname
sed "s/__HOSTNAME__/${HOSTNAME}/g" "$SCRIPT_DIR/../files/hosts" >> /etc/hosts

echo "[chroot] Setting root password..."
echo "root:${ROOT_PASS}" | chpasswd

echo "[chroot] Creating user ${USERNAME}..."
useradd -m -G wheel "${USERNAME}"
echo "${USERNAME}:${USER_PASS}" | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo "[chroot] Enabling NetworkManager..."
systemctl enable NetworkManager

echo "[chroot] Enabling Bluetooth..."
systemctl enable bluetooth

echo "[chroot] Configuring audio (SOF firmware for Gemini Lake)..."
# Ensure SOF firmware loads correctly for ES8336/Gemini Lake laptops
mkdir -p /etc/modprobe.d
cat > /etc/modprobe.d/sof.conf << 'EOF'
options snd_sof_pci_intel_apl ec_support=1
EOF

# Enable pipewire user services for the new user via systemd presets
# (systemctl --user can't run in chroot, so we use wants symlinks directly)
PIPEWIRE_WANTS="/home/${USERNAME}/.config/systemd/user/default.target.wants"
mkdir -p "$PIPEWIRE_WANTS"
for svc in pipewire.service pipewire-pulse.service wireplumber.service; do
    ln -sf "/usr/lib/systemd/user/${svc}" "$PIPEWIRE_WANTS/${svc}" 2>/dev/null || true
done
chown -R "${USERNAME}:${USERNAME}" "/home/${USERNAME}/.config"
echo "[chroot] Pipewire user services enabled for ${USERNAME}."

echo "[chroot] Running GRUB module..."
bash "$SCRIPT_DIR/grub.sh"

echo "[chroot] Running ZRAM module..."
bash "$SCRIPT_DIR/zram.sh"

echo "[chroot] Configuration complete."
