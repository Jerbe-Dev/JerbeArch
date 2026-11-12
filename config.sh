#!/usr/bin/env bash
# config.sh — edit these values, everything else reads from here

HOSTNAME="ArchOS-Larptop"
USERNAME="jerbe"
TIMEZONE="Asia/Manila"
LOCALE="en_US.UTF-8"

# Partition sizes in MiB.
EFI_SIZE_MIB=512
SWAP_SIZE_MIB=4096

# zram-generator settings.
ZRAM_SIZE=4096
ZRAM_ALGO="zstd"

# Keep the base install plain. Nocturne installs desktop, audio,
# Bluetooth, development tools, shell, and application packages.
EXTRA_PACKAGES=""

# Disk is chosen interactively at runtime.
DISK=""
