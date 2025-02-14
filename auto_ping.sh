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
[ ! -f "$CONFIG_FILE" ] && echo "TARGET_URLS=
PING_METHOD=
INTERFACE=
TUNNEL=
AUTOBOOT=
STATUS=inactive" > "$CONFIG_FILE"

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

# Fungsi untuk menjalankan wizard konfigurasi
konfigurasi_wizard() {
    echo "Masukkan URL target ping (pisahkan dengan spasi jika lebih dari satu):"; read -a TARGET_URLS
    echo "Pilih metode ping: (1) ping -c4 (2) adb shell ping -c4"
    read PING_CHOICE
    [ "$PING_CHOICE" == "1" ] && PING_METHOD="ping -c4"
    [ "$PING_CHOICE" == "2" ] && PING_METHOD="adb shell ping -c4"
    
    echo "Pilih interface (eth1, usb0, wwan0):"; read INTERFACE
    echo "Pilih tunnel restart (1) passwall (2) openclash (3) mihomo (4) tanpa restart"
    read TUNNEL_CHOICE
    case $TUNNEL_CHOICE in
        1) TUNNEL="restart passwall";;
        2) TUNNEL="restart openclash";;
        3) TUNNEL="restart mihomo";;
        4) TUNNEL="tanpa restart";;
    esac
    echo "Auto boot saat OpenWRT menyala? (yes/no):"; read AUTOBOOT
    echo "TARGET_URLS=${TARGET_URLS[*]}" > "$CONFIG_FILE"
    echo "PING_METHOD=$PING_METHOD" >> "$CONFIG_FILE"
    echo "INTERFACE=$INTERFACE" >> "$CONFIG_FILE"
    echo "TUNNEL=$TUNNEL" >> "$CONFIG_FILE"
    echo "AUTOBOOT=$AUTOBOOT" >> "$CONFIG_FILE"
    echo "STATUS=inactive" >> "$CONFIG_FILE"
}

# Fungsi untuk menjalankan auto ping secara berulang dan mencatat log
jalankan_auto_ping() {
    source "$CONFIG_FILE"
    echo "Auto Ping dimulai... (Tekan CTRL+C untuk berhenti)"
    while true; do
        for URL in $TARGET_URLS; do
            if eval "$PING_METHOD $URL" | tee -a "$LOG_FILE" | grep -q '100% packet loss'; then
                tulis_log "Ping ke $URL gagal (100% packet loss)"
            else
                tulis_log "Ping ke $URL sukses"
            fi
        done
        sleep 10
    done
}

# Fungsi untuk menjalankan script secara otomatis di latar belakang
jalankan_background() {
    nohup bash -c 'while true; do jalankan_auto_ping; sleep 10; done' >> "$LOG_FILE" 2>&1 &
    tulis_log "Script tetap berjalan di latar belakang."
}

# Fungsi untuk menjalankan script
jalankan_script() {
    source "$CONFIG_FILE"
    STATUS="active"
    echo "STATUS=$STATUS" > "$CONFIG_FILE"
    tulis_log "Script berhasil dijalankan dan akan berjalan terus!"
    sleep 2  # Menunggu sebentar sebelum kembali ke menu
    jalankan_background  # Pastikan script tetap berjalan di latar belakang
    menu_utama  # Kembali ke menu utama setelah menjalankan script
}

# Pastikan script berjalan otomatis saat booting
if ! grep -q "auto_ping &" /etc/rc.local; then
    sed -i -e '$i \nauto_ping &\n' /etc/rc.local
fi

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
            3) echo "STATUS=inactive" > "$CONFIG_FILE"; tulis_log "Script dihentikan.";;
            4) echo "Tekan ENTER untuk keluar dari log."; tail -f "$LOG_FILE" & read -r; kill $!;;
            5) exit;;
            *) echo "Pilihan tidak valid";;
        esac
    done
}

# Jalankan menu utama
menu_utama
