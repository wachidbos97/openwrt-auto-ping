# Panduan Instalasi dan Penggunaan Auto Ping + Restart Tunnel untuk OpenWRT

## 1. Unduh dan Simpan Script
Unduh script dengan perintah berikut di terminal OpenWRT:
```
wget -O /usr/bin/auto_ping "https://github.com/wachidbos97/openwrt-auto-ping"
chmod +x /usr/bin/auto_ping
```
Gantilah `URL_SCRIPT` dengan tautan unduhan yang sesuai.

## 2. Jalankan Script
Untuk menjalankan script, gunakan perintah berikut:
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

## 6. Auto Boot Saat OpenWRT Menyala (Default Aktif)
Secara default, script akan berjalan otomatis saat perangkat OpenWRT menyala. Jika ingin memastikan, jalankan perintah berikut:
```
if ! grep -q "auto_ping &" /etc/rc.local; then
    sed -i -e '$i \nauto_ping &\n' /etc/rc.local
fi
```
Pastikan perintah ini ada sebelum `exit 0` di dalam file `/etc/rc.local`.

## 7. Melanjutkan Auto Ping Setelah Reboot
Jika OpenWRT mati saat script auto ping masih berjalan, sistem akan otomatis melanjutkan script setelah menyala kembali. Untuk memastikan fitur ini aktif, jalankan perintah berikut:
```
if ! grep -q "auto_ping --resume &" /etc/rc.local; then
    sed -i -e '$i \nauto_ping --resume &\n' /etc/rc.local
fi
```
Perintah ini akan menjalankan kembali script dengan mode resume untuk melanjutkan ping tanpa perlu konfigurasi ulang.

## 8. Menghapus Log Secara Otomatis
Script secara otomatis akan menghapus log jika melebihi 100 baris untuk mencegah penggunaan memori berlebih.

## 9. Mengedit Konfigurasi
Jika ingin mengubah konfigurasi tanpa menjalankan ulang wizard, edit file `/etc/openwrt_auto_ping.conf` dengan editor teks seperti `nano` atau `vi`.

---
### Selesai! 🎉
Sekarang OpenWRT Anda bisa melakukan auto ping dan restart tunnel secara otomatis, bahkan setelah reboot. 🚀

