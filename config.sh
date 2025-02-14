# config.sh

#!/bin/bash

CONFIG_FILE="/etc/openwrt_auto_ping.conf"

# Periksa dan instal program pendukung jika belum ada
dependency_check() {
    for pkg in curl adb grep sed; do
        if ! command -v $pkg &> /dev/null; then
            echo "Paket $pkg tidak ditemukan, mencoba menginstalnya..."
            opkg update && opkg install $pkg
        fi
    done
}

# Memuat konfigurasi dari file
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        echo "TARGET_URLS=\nPING_METHOD=\nINTERFACE=\nTUNNEL=\nAUTOBOOT=\nSTATUS=inactive" > "$CONFIG_FILE"
        source "$CONFIG_FILE"
    fi
}

# Menyimpan konfigurasi ke file
save_config() {
    cat <<EOL > "$CONFIG_FILE"
TARGET_URLS=${TARGET_URLS[*]}
PING_METHOD="$PING_METHOD"
INTERFACE="$INTERFACE"
TUNNEL="$TUNNEL"
AUTOBOOT="$AUTOBOOT"
STATUS="$STATUS"
EOL
}
