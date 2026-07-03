#!/usr/bin/env bash
# scripts/cleanup.sh — unmount and finish up

do_cleanup() {
    log "Removing setup files from installed system..."
    rm -rf /mnt/root/JerbeArch-setup

    log "Unmounting..."
    umount -R /mnt

    log "Installation complete."
    read -rp "Reboot now? (y/N): " DO_REBOOT
    if [[ "$DO_REBOOT" =~ ^[Yy]$ ]]; then
        reboot
    fi
}
