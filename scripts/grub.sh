#!/usr/bin/env bash
# scripts/grub.sh — runs INSIDE arch-chroot, installs GRUB with a UEFI fallback
set -euo pipefail

echo "[grub] Installing the normal GRUB UEFI entry..."
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

echo "[grub] Installing the removable-media fallback bootloader..."
# This writes EFI/BOOT/BOOTX64.EFI so UEFI firmware can find GRUB
# even if a CMOS/BIOS reset erases the saved NVRAM boot entry.
grub-install --target=x86_64-efi --efi-directory=/boot --removable

# The ECS CP43IGL reports the ES8336 headphone jack with reversed polarity.
# Keep the detected SSP2 bit (0x02) and add JD_INVERTED (0x40): 0x42 / 66.
# Only apply this board-specific override when the target machine identifies
# itself as CP43IGL; other machines keep their kernel defaults.
if grep -qi 'CP43IGL' /sys/class/dmi/id/product_name /sys/class/dmi/id/board_name /sys/class/dmi/id/product_version /proc/asound/card0/longname 2>/dev/null; then
    echo "[grub] Applying ECS CP43IGL ES8336 inverted-jack quirk (0x42)..."
    cp -an /etc/default/grub /etc/default/grub.before-jerbearch-audio

    # Remove any previous value from either GRUB command-line variable.
    sed -i -E '/^GRUB_CMDLINE_LINUX(_DEFAULT)?=/ {
        s/[[:space:]]*snd_soc_sof_es8336\\.quirk=[^ "]+//g
    }' /etc/default/grub

    if grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=' /etc/default/grub; then
        sed -i -E '/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/"$/ snd_soc_sof_es8336.quirk=66"/' /etc/default/grub
    else
        echo 'GRUB_CMDLINE_LINUX_DEFAULT="snd_soc_sof_es8336.quirk=66"' >> /etc/default/grub
    fi

    if ! grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=.*snd_soc_sof_es8336\\.quirk=66' /etc/default/grub; then
        echo "[grub] ERROR: Could not add the ES8336 quirk to GRUB defaults." >&2
        exit 1
    fi
else
    echo "[grub] CP43IGL not detected; leaving kernel audio parameters unchanged."
fi

echo "[grub] Generating GRUB config..."
grub-mkconfig -o /boot/grub/grub.cfg

echo "[grub] Normal and fallback UEFI boot paths are installed."
