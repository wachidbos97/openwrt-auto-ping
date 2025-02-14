# auto_ping.sh

#!/bin/bash

source config.sh
source log.sh

# Fungsi untuk menjalankan auto ping secara berulang
jalankan_auto_ping() {
    load_config
    local loss_count=0
    echo "Auto Ping dimulai... (Tekan CTRL+C untuk berhenti)"
    while true; do
        local all_failed=true
        for URL in $TARGET_URLS; do
            if eval "$PING_METHOD -I $INTERFACE -c4 $URL" | tee -a "$LOG_FILE" | grep -q '100% packet loss'; then
                tulis_log "Ping ke $URL gagal (100% packet loss)"
                loss_count=$((loss_count + 1))
            else
                tulis_log "Ping ke $URL sukses"
                all_failed=false
                loss_count=0
            fi
        done
        if [ "$loss_count" -ge 10 ]; then
            tulis_log "Ping gagal 10 kali berturut-turut, mencoba restart tunnel jika dikonfigurasi"
            case "$TUNNEL" in
                "restart passwall") /etc/init.d/passwall restart;;
                "restart openclash") /etc/init.d/openclash restart;;
                "restart mihomo") /etc/init.d/mihomo restart;;
                "tanpa restart") tulis_log "Restart tunnel tidak dipilih, lanjut auto ping.";;
                *) tulis_log "Tunnel tidak dikonfigurasi, melewati restart.";;
            esac
            loss_count=0
        fi
        sleep 3
    done
}
