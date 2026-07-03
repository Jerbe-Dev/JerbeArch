#!/usr/bin/env bash
# scripts/zram.sh — runs INSIDE arch-chroot, configures zram-generator
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config.sh"

echo "[zram] Writing zram-generator config (${ZRAM_SIZE}, ${ZRAM_ALGO})..."
cat > /etc/systemd/zram-generator.conf <<EOF
[zram0]
zram-size = ${ZRAM_SIZE}
compression-algorithm = ${ZRAM_ALGO}
swap-priority = 100
EOF
