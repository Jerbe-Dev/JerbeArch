# JerbeArch

A modular, scriptable Arch Linux installer. UEFI + GRUB + ext4 + zram, one
disk, no desktop environment — a minimal base you can build on.

## What it does

From the Arch ISO, `install.sh` will:

1. Confirm UEFI boot mode
2. Optionally connect to WiFi via `iwctl`
3. Let you pick a disk and **require typing `YES`** before wiping it
4. Partition: EFI / swap / ext4 root
5. Format and mount
6. `pacstrap` the base system + your extra packages
7. Generate `fstab`
8. Chroot in and configure: timezone, locale, hostname, root + user
   passwords, sudo, NetworkManager, GRUB, zram
9. Unmount and optionally reboot

## Usage

```bash
pacman -Sy git
git clone https://github.com/<your-username>/JerbeArch.git
cd JerbeArch
chmod +x install.sh
./install.sh
```

Answer the prompts (disk, WiFi if needed, passwords). Everything else comes
from `config.sh`.

## Configuration

Edit `config.sh` before running to change defaults:

```bash
HOSTNAME="ArchOS-Larptop"
USERNAME="jerbe"
TIMEZONE="Asia/Manila"
LOCALE="en_US.UTF-8"

EFI_SIZE="512M"
SWAP_SIZE="4G"
ZRAM_SIZE="4G"
ZRAM_ALGO="zstd"

EXTRA_PACKAGES="base-devel"
DISK=""   # leave empty to be prompted; set e.g. "/dev/sda" to skip the prompt
```

## Repository structure

```text
JerbeArch/
├── install.sh          # Main entry point
├── config.sh            # Your settings
├── scripts/
│   ├── common.sh         # Shared helpers (log/warn/die, UEFI + internet checks)
│   ├── wifi.sh            # Optional iwctl WiFi connection
│   ├── partition.sh       # Disk selection, confirmation, partitioning
│   ├── format.sh           # mkfs + mount
│   ├── pacstrap.sh          # Base install + fstab
│   ├── chroot.sh             # Runs inside arch-chroot: timezone/locale/users/etc
│   ├── grub.sh                 # GRUB install (called from chroot.sh)
│   ├── zram.sh                  # zram-generator config (called from chroot.sh)
│   └── cleanup.sh               # Unmount + reboot prompt
├── files/
│   ├── hosts              # /etc/hosts template
│   └── locale.conf         # /etc/locale.conf template
├── README.md
└── LICENSE
```

## Safety notes

- The script **erases the selected disk**. Double-check `DISK` / your
  selection at the prompt before typing `YES`.
- Passwords are asked for interactively (not stored in the repo) and passed
  into the chroot as environment variables, unset immediately after use.
- `set -euo pipefail` is used throughout — any failed command stops the
  install rather than continuing in a broken state.

## Disclaimer

This is a personal setup script. Read it before you run it, especially if
you fork it for your own hardware — partition sizes, package lists, and
locale/timezone are tuned for one person's laptop, not yours.
