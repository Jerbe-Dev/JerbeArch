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
    echo " Partitions  : $PART1 (EFI ${EFI_SIZE_MIB}MiB) / $PART2 (swap ${SWAP_SIZE_MIB}MiB) / $PART3 (root, rest of disk)"
    echo " Hostname    : $HOSTNAME"
    echo " Username    : $USERNAME"
    echo " Timezone    : $TIMEZONE"
    echo " ZRAM size   : ${ZRAM_SIZE}M ($ZRAM_ALGO)"
    echo "=========================================="
    warn "THIS WILL ERASE ALL DATA ON $DISK."
    read -rp "Type YES (all caps) to continue: " CONFIRM
    [[ "$CONFIRM" == "YES" ]] || die "Aborted. No changes made."
}

do_partition() {
    log "Wiping and partitioning $DISK..."
    sgdisk --zap-all "$DISK"
    parted -s "$DISK" mklabel gpt

    # Plain MiB integer math, and "MiB" passed explicitly to parted every
    # time. Never mix bare "G"/"M" (which parted treats as decimal GB/MB)
    # with binary GiB/MiB expectations -- that mismatch was why swap showed
    # up as ~3.7G instead of a true 4G.
    local swap_end_mib=$(( EFI_SIZE_MIB + SWAP_SIZE_MIB ))

    parted -s "$DISK" mkpart ESP fat32 1MiB "${EFI_SIZE_MIB}MiB"
    parted -s "$DISK" set 1 esp on
    parted -s "$DISK" mkpart primary linux-swap "${EFI_SIZE_MIB}MiB" "${swap_end_mib}MiB"
    parted -s "$DISK" mkpart primary ext4 "${swap_end_mib}MiB" 100%

    partprobe "$DISK"
    sleep 2
    log "Partitioning done."
}
