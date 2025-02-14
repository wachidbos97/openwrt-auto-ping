# auto_ping_main.sh

#!/bin/bash

# Load modules
source config.sh
source log.sh
source auto_ping.sh
source menu.sh

# Pastikan script berjalan otomatis saat booting
if ! grep -q "auto_ping &" /etc/rc.local; then
    sed -i -e '$i \nauto_ping &\n' /etc/rc.local
fi

# Jalankan menu utama
menu_utama
