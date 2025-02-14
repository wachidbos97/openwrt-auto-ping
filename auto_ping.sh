#!/bin/bash

CONFIG_FILE="/etc/openwrt_auto_ping.conf"
LOG_FILE="/var/log/openwrt_auto_ping.log"
MAX_LOG_LINES=100

# Periksa dan instal program pendukung jika belum ada
dependency_check() {
    for pkg in curl adb grep sed; do
        if ! command -v $pkg &> /dev/null; then
            echo "Paket $pkg tidak ditemukan, mencoba menginstalnya..."
            opkg update && opkg install $pkg
        fi
    done
}

dependency_check

# Pastikan file konfigurasi ada agar tidak kosong saat pertama kali dijalankan
[ ! -f "$CONFIG_FILE" ] && cat <<EOL > "$CONFIG_FILE"
TARGET_URLS=
PING_METHOD=
INTERFACE=
TUNNEL=
AUTOBOOT=
STATUS=inactive
EOL

# Fungsi untuk menyimpan konfigurasi
simpan_konfigurasi() {
    cat <<EOL > "$CONFIG_FILE"
TARGET_URLS=${TARGET_URLS[*]}
PING_METHOD=$PING_METHOD
INTERFACE=$INTERFACE
TUNNEL=$TUNNEL
AUTOBOOT=$AUTOBOOT
STATUS=$STATUS
EOL
}

# Fungsi untuk menampilkan status konfigurasi di dashboard
status_dashboard() {
    clear
    source "$CONFIG_FILE"
    echo "=== DASHBOARD KONFIGURASI ==="
    echo "1) URL Target Ping: ${TARGET_URLS:-Belum dikonfigurasi}"
    echo "2) Metode Ping: ${PING_METHOD:-Belum dikonfigurasi}"
    echo "3) Target Interface: ${INTERFACE:-Belum dikonfigurasi}"
    echo "4) Target Tunnel: ${TUNNEL:-Belum dikonfigurasi}"
    echo "5) Auto Boot: ${AUTOBOOT:-Belum dikonfigurasi}"
    echo "6) Status Script: ${STATUS:-inactive}"
    echo "================================"
}

# Fungsi untuk menjalankan wizard konfigurasi jika belum dikonfigurasi
cek_konfigurasi() {
    source "$CONFIG_FILE"
    if [ -z "$TARGET_URLS" ] || [ -z "$PING_METHOD" ] || [ -z "$INTERFACE" ] || [ -z "$TUNNEL" ] || [ -z "$AUTOBOOT" ]; then
        echo "Konfigurasi belum lengkap, harap isi wizard konfigurasi."
        konfigurasi_wizard
    fi
}

# Fungsi untuk menjalankan auto ping secara berulang dengan barometer 100% packet loss
jalankan_auto_ping() {
    source "$CONFIG_FILE"
    local loss_count=0
    echo "Auto Ping dimulai... (Tekan CTRL+C untuk berhenti)"
    while true; do
        local all_failed=true
        for URL in $TARGET_URLS; do
            if $PING_METHOD $URL | grep -q '100% packet loss'; then
                echo "Ping ke $URL gagal (100% packet loss)"
            else
                echo "Ping ke $URL sukses"
                all_failed=false
            fi
        done
        if $all_failed; then
            loss_count=$((loss_count + 1))
            echo "Auto Ping gagal $loss_count kali berturut-turut."
            if [ "$loss_count" -ge 10 ] && [ "$TUNNEL" != "tanpa restart" ]; then
                echo "Restarting tunnel: $TUNNEL..."
                case $TUNNEL in
                    "restart passwall") /etc/init.d/passwall restart;;
                    "restart openclash") /etc/init.d/openclash restart;;
                    "restart mihomo") /etc/init.d/mihomo restart;;
                esac
                loss_count=0
            fi
        else
            loss_count=0
            echo "Ping berhasil, mengulangi auto ping dari awal."
        fi
        sleep 3
    done
}

# Fungsi untuk menjalankan script
jalankan_script() {
    source "$CONFIG_FILE"
    STATUS="active"
    simpan_konfigurasi
    echo "Script berhasil dijalankan dan akan berjalan terus!"  # Menampilkan pesan sukses
    sleep 2  # Menunggu sebentar sebelum kembali ke menu
    jalankan_auto_ping  # Jalankan auto ping langsung
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
            3) echo "STATUS=inactive" > "$CONFIG_FILE"; simpan_konfigurasi; echo "Script dihentikan.";;
            4) echo "Tekan ENTER untuk keluar dari log."; tail -f "$LOG_FILE" & read -r; kill $!;;
            5) exit;;
            *) echo "Pilihan tidak valid";;
        esac
    done
}

# Jalankan menu utama
menu_utama
