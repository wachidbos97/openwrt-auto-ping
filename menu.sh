# menu.sh

#!/bin/bash

source config.sh
source log.sh
source auto_ping.sh


# Fungsi untuk menampilkan status konfigurasi di dashboard
status_dashboard() {
    clear
    load_config
    echo "=== DASHBOARD KONFIGURASI ==="
    echo "1) URL Target Ping: ${TARGET_URLS:-Belum dikonfigurasi}"
    echo "2) Metode Ping: ${PING_METHOD:-Belum dikonfigurasi}"
    echo "3) Target Interface: ${INTERFACE:-Belum dikonfigurasi}"
    echo "4) Target Tunnel: ${TUNNEL:-Belum dikonfigurasi}"
    echo "5) Auto Boot: ${AUTOBOOT:-Belum dikonfigurasi}"
    echo "6) Status Script: ${STATUS:-inactive}"
    echo "================================"
}

# Fungsi untuk menampilkan menu utama
menu_utama() {
    status_dashboard
    while true; do
        echo "=== MENU UTAMA ==="
        echo "1) Konfigurasi"
        echo "2) Aktifkan Script"
        echo "3) Nonaktifkan Script"
        echo "4) Tampilkan Log"
        echo "5) Exit"
        echo "=================="
        read -p "Pilih opsi: " choice
        case $choice in
            1) konfigurasi_wizard;;
            2) cek_konfigurasi; jalankan_script;;
            3) echo "STATUS=inactive" > "$CONFIG_FILE"; save_config; tulis_log "Script dihentikan.";;
            4) echo "Tekan ENTER untuk keluar dari log."; tail -f "$LOG_FILE" & read -r; kill $!;;
            5) exit;;
            *) echo "Pilihan tidak valid";;
        esac
    done
}
