#!/usr/bin/env bash
# config.sh — edit these values, everything else reads from here

HOSTNAME="ArchOS-Larptop"
USERNAME="jerbe"
TIMEZONE="Asia/Manila"
LOCALE="en_US.UTF-8"

# Sizes are plain MiB integers (no suffix) — this avoids the parted
# decimal-GB vs lsblk binary-GiB mismatch that made swap show up as
# "3.7G" instead of 4G when it was created with a "4G" (=4000MB) size.
EFI_SIZE_MIB=512
SWAP_SIZE_MIB=4096

# zram-generator's config expects a bare MiB number (or arithmetic
# expression), not a "4G"-style suffix — that mismatch is the likely
# reason zram wasn't coming up at all.
ZRAM_SIZE=4096
ZRAM_ALGO="zstd"

# Extra packages installed at pacstrap time (space separated)
EXTRA_PACKAGES="base-devel"

# Disk is chosen interactively at runtime (see scripts/partition.sh),
# but you can hardcode a default here if you always install on the same box.
# Leave empty to always be prompted.
DISK=""
