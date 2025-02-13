# Panduan Instalasi dan Penggunaan Auto Ping + Restart Tunnel untuk OpenWRT

## 1. Unduh, Instal, dan Konfigurasi Auto Boot (Satu Perintah)
Jalankan perintah berikut di terminal OpenWRT:
```
wget -O /usr/bin/auto_ping "https://raw.githubusercontent.com/wachidbos97/openwrt-auto-ping/main/auto_ping.sh" && \
chmod +x /usr/bin/auto_ping && \
if ! grep -q "auto_ping &" /etc/rc.local; then sed -i -e '$i \nauto_ping &\n' /etc/rc.local; fi && \
if ! grep -q "auto_ping --resume &" /etc/rc.local; then sed -i -e '$i \nauto_ping --resume &\n' /etc/rc.local; fi
```
Perintah ini akan mengunduh script, memberikan izin eksekusi, dan mengatur agar script otomatis berjalan setelah OpenWRT menyala kembali.

## 2. Jalankan Script
Setelah instalasi selesai, jalankan script dengan perintah:
```
auto_ping
```

## 3. Konfigurasi Awal
Saat pertama kali menjalankan script, Anda akan diminta untuk:
- Memasukkan URL target ping (bisa lebih dari satu)
- Memilih metode ping
- Memilih interface jaringan
- Memilih tunnel yang akan direstart jika ping gagal

Setelah konfigurasi selesai, data akan disimpan dan dapat digunakan kembali.

## 4. Mengaktifkan dan Menonaktifkan Script
- Untuk mengaktifkan script, jalankan kembali `auto_ping` dan pilih opsi "Aktifkan Script"
- Untuk menonaktifkan script, pilih "Nonaktifkan Script"

## 5. Melihat Log
Untuk melihat log proses secara real-time, pilih opsi "Tampilkan Log" pada menu.
- Log menampilkan jam dan tanggal setiap proses ping
- Tekan `ENTER` untuk keluar dari log

## 6. Mengedit Konfigurasi Secara Manual
Jika ingin mengubah konfigurasi tanpa menjalankan ulang wizard, edit file `/etc/openwrt_auto_ping.conf`:
```
nano /etc/openwrt_auto_ping.conf
```
Simpan perubahan dengan `CTRL + X`, ketik `Y`, dan tekan `ENTER`.

## 7. Menghapus Log Secara Otomatis
Script secara otomatis akan menghapus log jika melebihi 100 baris untuk mencegah penggunaan memori berlebih.

## 8. Menghapus Script
Jika ingin menghapus script dari OpenWRT:
```
rm /usr/bin/auto_ping
rm /etc/openwrt_auto_ping.conf
```

---
### Selesai! 🎉
Sekarang OpenWRT Anda bisa melakukan auto ping dan restart tunnel secara otomatis, bahkan setelah reboot. 🚀
