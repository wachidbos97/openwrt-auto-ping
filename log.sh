# log.sh

#!/bin/bash

LOG_FILE="/var/log/openwrt_auto_ping.log"
MAX_LOG_LINES=100

# Fungsi untuk mencatat log real-time
tulis_log() {
    local pesan="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp - $pesan" | tee -a "$LOG_FILE"
    
    # Hapus log jika lebih dari MAX_LOG_LINES
    if [ $(wc -l < "$LOG_FILE") -gt $MAX_LOG_LINES ]; then
        tail -n $MAX_LOG_LINES "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
    fi
}
