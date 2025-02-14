# Panduan Instalasi Auto Ping untuk OpenWRT

## Cara Instalasi (Satu Perintah)
Gunakan perintah berikut untuk memastikan semua paket yang dibutuhkan terinstal, membuat folder instalasi, mengunduh script, mengganti file lama, dan memberikan izin eksekusi:
```sh
opkg update && opkg install curl adb grep sed coreutils
mkdir -p /usr/bin/autoping
for file in auto_ping_main.sh config.sh log.sh auto_ping.sh menu.sh; do
    wget -O /usr/bin/autoping/$file "https://raw.githubusercontent.com/wachidbos97/openwrt-auto-ping/main/$file"
    chmod +x /usr/bin/autoping/$file
done
ln -sf /usr/bin/autoping/auto_ping_main.sh /usr/bin/auto-ping
```

Setelah instalasi selesai, jalankan script dengan:
```sh
auto-ping
```

## Menyesuaikan Path dalam Script
Agar semua script saling terhubung setelah berpindah ke `/usr/bin/autoping/`, pastikan setiap file `.sh` di dalam folder tersebut menggunakan path absolut saat **source**:
```sh
source /usr/bin/autoping/config.sh
source /usr/bin/autoping/log.sh
source /usr/bin/autoping/auto_ping.sh
source /usr/bin/autoping/menu.sh
```

## Fitur
- **Ping otomatis** ke URL yang telah dikonfigurasi.
- **Restart tunnel otomatis** jika ping gagal sesuai batas yang ditentukan.
- **Barometer 100% packet loss untuk menentukan kegagalan auto ping**.
- **Ping akan diulang setiap 3 detik jika berhasil**.
- **Jika auto ping gagal 10 kali berturut-turut, tunnel akan direstart**.
- **Menjaga proses tetap berjalan meskipun keluar dari terminal**.
- **Dashboard status** menampilkan informasi konfigurasi yang tersimpan.
- **Shortcut `auto-ping` untuk menjalankan script dengan mudah**.

## Cara Konfigurasi
1. Jalankan perintah `auto-ping`
2. Masuk ke menu **Konfigurasi** dan isi:
   - **URL target ping**
   - **Metode ping** (`ping` biasa atau `adb shell ping`)
   - **Interface jaringan**
   - **Tunnel yang akan direstart jika ping gagal**
   - **Opsi auto boot**
3. Setelah selesai, pilih **Aktifkan Script**

## Troubleshooting
- Jika skrip tidak berjalan, pastikan sudah diberi izin eksekusi:
  ```sh
  chmod +x /usr/bin/autoping/auto_ping_main.sh
  ```

Skrip sekarang siap digunakan! 🚀

