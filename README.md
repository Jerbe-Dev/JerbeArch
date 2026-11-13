# JerbeArch

A minimal, scriptable Arch Linux base installer for the Nocturne desktop setup. UEFI + GRUB + ext4 + swap + zram, one disk, no desktop environment or desktop applications.

## What it installs

From the Arch ISO, `install.sh` will:

1. Confirm UEFI boot mode
2. Optionally connect to WiFi via `iwctl`
3. Let you pick a disk and **require typing `YES`** before wiping it
4. Partition: EFI / swap / ext4 root
5. Format and mount
6. Install only the base system and essential boot/network tools
7. Generate `fstab`
8. Configure timezone, locale, hostname, root + user passwords, sudo, and NetworkManager
9. Install GRUB both as a normal UEFI entry and at the fallback path `EFI/BOOT/BOOTX64.EFI`
   - On ECS CP43IGL hardware, preserve the SSP2 setting and enable the ES8336 inverted-headphone-jack quirk (`snd_soc_sof_es8336.quirk=66`).
10. Configure zram
11. Unmount and optionally reboot

## Package split

JerbeArch deliberately keeps the installed system plain.

**JerbeArch installs:**
- `base`, `linux`, `linux-firmware`
- `nano`
- `networkmanager`
- `sudo`
- `grub`, `efibootmgr`
- `zram-generator`

**Nocturne installs later:**
- Niri, Noctalia, and desktop/session components
- Audio stack and hardware audio firmware/configuration
- Bluetooth packages and services
- Fish/Zsh, Starship/Powerlevel10k, and terminal setup
- Development tools, AUR helpers, applications, themes, and plugins

This avoids installing desktop packages twice. NetworkManager is kept in the base so the installed system can connect to the internet before Nocturne is installed.

## Usage

```bash
pacman -Sy git
git clone https://github.com/Jerbe-Dev/JerbeArch.git
cd JerbeArch
chmod +x install.sh
./install.sh
```

Answer the prompts (disk, WiFi if needed, passwords). Defaults come from `config.sh`.

## Configuration

Edit `config.sh` before running to change defaults:

```bash
HOSTNAME="ArchOS-Larptop"
USERNAME="jerbe"
TIMEZONE="Asia/Manila"
LOCALE="en_US.UTF-8"

EFI_SIZE_MIB=512
SWAP_SIZE_MIB=4096
ZRAM_SIZE=4096
ZRAM_ALGO="zstd"

EXTRA_PACKAGES=""
DISK=""   # leave empty to be prompted; set e.g. "/dev/sda" to skip the prompt
```

The default extra package list is intentionally empty. Add packages only if you specifically want them in the base install.

## Repository structure

```text
JerbeArch/
├── install.sh
├── config.sh
├── scripts/
│   ├── common.sh
│   ├── wifi.sh
│   ├── partition.sh
│   ├── format.sh
│   ├── pacstrap.sh
│   ├── chroot.sh
│   ├── grub.sh
│   ├── zram.sh
│   └── cleanup.sh
├── files/
│   ├── hosts
│   └── locale.conf
├── README.md
└── LICENSE
```

## Safety notes

- The script **erases the selected disk**. Double-check `DISK` / your selection at the prompt before typing `YES`.
- Passwords are asked for interactively (not stored in the repo) and passed into the chroot as environment variables, unset immediately after use.
- `set -euo pipefail` is used throughout — any failed command stops the install rather than continuing in a broken state.

## UEFI boot recovery protection

JerbeArch installs GRUB in two places:

- The normal `GRUB` UEFI boot entry
- The standard removable-media fallback path `EFI/BOOT/BOOTX64.EFI`

The fallback path can let compatible UEFI firmware boot Arch even if a CMOS/BIOS reset erases the saved `GRUB` NVRAM entry. It does not prevent the firmware clock/settings from resetting, repair a failing RTC/CMOS battery, or help if firmware is switched to Legacy/CSM mode. Keep firmware boot mode set to UEFI. If the laptop repeatedly loses its clock/settings after battery drain, have the RTC/CMOS battery and its connection checked.
