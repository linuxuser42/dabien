#!/bin/bash

#https://www.e-boks.dk
script=`pwd`/dabien_live_usb.sh
png=`pwd`/dabien.svg
thispath=`pwd`
[ -f $script ]  && cat << EOF > /usr/share/applications/dabien_live_usb.desktop
[Desktop Entry]
Name=dabien Live Usb
Comment=Make a dabien key
Exec=gksu ${script}
Icon=${png}
Type=Application
Path=${thispath}
Keywords=accessories;system;dabien;clone;make;
EOF

