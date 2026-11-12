#!/usr/bin/env bash
# scripts/grub.sh — runs INSIDE arch-chroot, installs GRUB with a UEFI fallback
set -euo pipefail

echo "[grub] Installing the normal GRUB UEFI entry..."
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

echo "[grub] Installing the removable-media fallback bootloader..."
# This writes EFI/BOOT/BOOTX64.EFI so UEFI firmware can find GRUB
# even if a CMOS/BIOS reset erases the saved NVRAM boot entry.
grub-install --target=x86_64-efi --efi-directory=/boot --removable

echo "[grub] Generating GRUB config..."
grub-mkconfig -o /boot/grub/grub.cfg

echo "[grub] Normal and fallback UEFI boot paths are installed."
