#!/bin/bash

#https://www.e-boks.dk
script=`pwd`/dabien_backup.sh
png=`pwd`/backup.svg
thispath=`pwd`
[ -f $script ]  && cat << EOF > /usr/share/applications/dabien_backup.desktop
[Desktop Entry]
Name=dabien Backup
Comment=Backup to secondary Dabien key
Exec=gksu ${script}
Icon=${png}
Type=Application
Path=${thispath}
Keywords=accessories;backup;system;dabien;clone;make;
EOF

