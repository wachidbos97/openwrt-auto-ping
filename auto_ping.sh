#!/bin/bash

CONFIG_FILE="/etc/openwrt_auto_ping.conf"
LOG_FILE="/var/log/openwrt_auto_ping.log"
MAX_LOG_LINES=100

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
    echo "=== DASHBOARD KONFIGURASI ==="
    source "$CONFIG_FILE"
    echo "1) URL Target Ping: $TARGET_URLS"
    echo "2) Metode Ping: $PING_METHOD"
    echo "3) Target Interface: $INTERFACE"
    echo "4) Target Tunnel: $TUNNEL"
    echo "5) Auto Boot: $AUTOBOOT"
    echo "6) Status Script: $STATUS"
    echo "================================"
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

# Fungsi untuk menjalankan ping dan restart tunnel jika semua URL gagal
jalankan_script() {
    source "$CONFIG_FILE"
    STATUS="active"
    echo "STATUS=$STATUS" > "$CONFIG_FILE"
    local loss_count=0
    while true; do
        local all_failed=true
        for URL in $TARGET_URLS; do
            if $PING_METHOD $URL > /dev/null; then
                all_failed=false
                break
            fi
        done
        TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
        if $all_failed; then
            loss_count=$((loss_count + 1))
            echo "$TIMESTAMP - Ping gagal ($loss_count/10), cek kembali..." | tee -a "$LOG_FILE"
            if [ "$loss_count" -ge 10 ]; then
                echo "$TIMESTAMP - Ping gagal 10 kali berturut-turut..." | tee -a "$LOG_FILE"
                if [ "$TUNNEL" != "tanpa restart" ]; then
                    echo "$TIMESTAMP - Restarting tunnel: $TUNNEL..." | tee -a "$LOG_FILE"
                    case $TUNNEL in
                        "restart passwall") /etc/init.d/passwall restart;;
                        "restart openclash") /etc/init.d/openclash restart;;
                        "restart mihomo") /etc/init.d/mihomo restart;;
                    esac
                fi
                loss_count=0
                continue
            fi
        else
            echo "$TIMESTAMP - Ping sukses ke salah satu target, lanjut cek..." | tee -a "$LOG_FILE"
            loss_count=0
        fi
        sleep 10

        # Hapus log jika lebih dari 100 baris
        if [ $(wc -l < "$LOG_FILE") -gt $MAX_LOG_LINES ]; then
            tail -n $MAX_LOG_LINES "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
        fi
    done
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
            2) jalankan_script;;
            3) echo "STATUS=inactive" > "$CONFIG_FILE"; echo "Script dinonaktifkan.";;
            4) echo "Tekan ENTER untuk keluar dari log."; tail -f "$LOG_FILE" & read -r; kill $!;;
            5) exit;;
            *) echo "Pilihan tidak valid";;
        esac
    done
}

# Jalankan menu utama
menu_utama
