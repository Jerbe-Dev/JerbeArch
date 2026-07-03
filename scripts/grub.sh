#!/usr/bin/env bash
# scripts/grub.sh — runs INSIDE arch-chroot, installs and configures GRUB
set -euo pipefail

echo "[grub] Installing GRUB..."
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

echo "[grub] Generating GRUB config..."
grub-mkconfig -o /boot/grub/grub.cfg
