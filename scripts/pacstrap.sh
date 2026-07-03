#!/usr/bin/env bash
# scripts/pacstrap.sh — install base system and generate fstab

do_pacstrap() {
    log "Installing base system (this takes a while)..."
    pacstrap /mnt base linux linux-firmware nano networkmanager sudo grub efibootmgr zram-generator $EXTRA_PACKAGES
}

do_fstab() {
    log "Generating fstab..."
    genfstab -U /mnt >> /mnt/etc/fstab
}
