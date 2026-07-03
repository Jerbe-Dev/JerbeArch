#!/usr/bin/env bash
# scripts/partition.sh — disk selection, confirmation, and partitioning

select_disk() {
    if [[ -n "$DISK" ]]; then
        log "Using disk from config.sh: $DISK"
    else
        echo "Available disks:"
        lsblk -dpno NAME,SIZE,MODEL | grep -E '^/dev/(sd|nvme|vd)'
        echo
        read -rp "Type the full path of the disk to install to (e.g. /dev/sda): " DISK
    fi

    [[ -b "$DISK" ]] || die "$DISK is not a valid block device."

    set_partition_names

    echo "=========================================="
    echo " Target disk : $DISK"
    echo " Partitions  : $PART1 (EFI $EFI_SIZE) / $PART2 (swap $SWAP_SIZE) / $PART3 (root, rest of disk)"
    echo " Hostname    : $HOSTNAME"
    echo " Username    : $USERNAME"
    echo " Timezone    : $TIMEZONE"
    echo " ZRAM size   : $ZRAM_SIZE ($ZRAM_ALGO)"
    echo "=========================================="
    warn "THIS WILL ERASE ALL DATA ON $DISK."
    read -rp "Type YES (all caps) to continue: " CONFIRM
    [[ "$CONFIRM" == "YES" ]] || die "Aborted. No changes made."
}

do_partition() {
    log "Wiping and partitioning $DISK..."
    sgdisk --zap-all "$DISK"
    parted -s "$DISK" mklabel gpt
    parted -s "$DISK" mkpart ESP fat32 1MiB "$EFI_SIZE"
    parted -s "$DISK" set 1 esp on

    local swap_end
    swap_end=$(numfmt --to=iec $(( $(numfmt --from=iec "$EFI_SIZE") + $(numfmt --from=iec "$SWAP_SIZE") )))

    parted -s "$DISK" mkpart primary linux-swap "$EFI_SIZE" "$swap_end"
    parted -s "$DISK" mkpart primary ext4 "$swap_end" 100%

    partprobe "$DISK"
    sleep 2
    log "Partitioning done."
}
