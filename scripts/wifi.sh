#!/usr/bin/env bash
# scripts/wifi.sh — optional WiFi setup via iwctl

connect_wifi() {
    read -rp "Do you need to connect to WiFi now? (y/N): " NEED_WIFI
    if [[ "$NEED_WIFI" =~ ^[Yy]$ ]]; then
        echo "Launching iwctl. Inside it, run:"
        echo "  device list"
        echo "  station wlan0 scan"
        echo "  station wlan0 get-networks"
        echo "  station wlan0 connect WIFI_NAME"
        echo "  exit"
        iwctl
    fi
}
