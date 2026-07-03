#!/usr/bin/env bash
# scripts/format.sh — format and mount partitions

do_format() {
    log "Formatting partitions..."
    mkfs.fat -F32 "$PART1"
    mkswap "$PART2"
    swapon "$PART2"
    mkfs.ext4 -F "$PART3"
}

do_mount() {
    log "Mounting partitions..."
    mount "$PART3" /mnt
    mkdir -p /mnt/boot
    mount "$PART1" /mnt/boot
}
