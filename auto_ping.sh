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

# Fungsi untuk menjalankan wizard konfigurasi hanya jika belum dikonfigurasi
cek_konfigurasi() {
    source "$CONFIG_FILE"
    if [ -z "$TARGET_URLS" ] || [ -z "$PING_METHOD" ] || [ -z "$INTERFACE" ] || [ -z "$TUNNEL" ] || [ -z "$AUTOBOOT" ]; then
        echo "Konfigurasi belum lengkap, harap isi wizard konfigurasi."
        konfigurasi_wizard
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

# Fungsi untuk memastikan script tetap berjalan setelah keluar
jalankan_background() {
    nohup bash -c 'while true; do jalankan_script; sleep 10; done' &> /dev/null &
    echo "Script tetap berjalan di latar belakang."
}

# Fungsi untuk menjalankan ping dan restart tunnel jika semua URL gagal
jalankan_script() {
    source "$CONFIG_FILE"
    STATUS="active"
    echo "STATUS=$STATUS" > "$CONFIG_FILE"
    echo "Script berhasil dijalankan!"  # Menampilkan pesan sukses
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
            3) echo "STATUS=inactive" > "$CONFIG_FILE"; echo "Script dinonaktifkan.";;
            4) echo "Tekan ENTER untuk keluar dari log."; tail -f "$LOG_FILE" & read -r; kill $!;;
            5) exit;;
            *) echo "Pilihan tidak valid";;
        esac
    done
}

# Jalankan menu utama
menu_utama
