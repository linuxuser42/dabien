#!/bin/bash

#https://www.e-boks.dk
script=`pwd`/dabien_restore.sh
png=`pwd`/restore.svg
thispath=`pwd`
[ -f $script ]  && cat << EOF > /usr/share/applications/dabien_restore.desktop
[Desktop Entry]
Name=dabien Restore
Comment=Restore homedir from seconday key
Exec=gksu ${script}
Icon=${png}
Type=Application
Path=${thispath}
Keywords=accessories;system;dabien;restore;
EOF

