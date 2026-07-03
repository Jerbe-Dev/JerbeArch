#!/usr/bin/env bash
# config.sh — edit these values, everything else reads from here

HOSTNAME="ArchOS-Larptop"
USERNAME="jerbe"
TIMEZONE="Asia/Manila"
LOCALE="en_US.UTF-8"

EFI_SIZE="512M"
SWAP_SIZE="4G"
ZRAM_SIZE="4G"
ZRAM_ALGO="zstd"

# Extra packages installed at pacstrap time (space separated)
EXTRA_PACKAGES="base-devel"

# Disk is chosen interactively at runtime (see scripts/partition.sh),
# but you can hardcode a default here if you always install on the same box.
# Leave empty to always be prompted.
DISK=""
