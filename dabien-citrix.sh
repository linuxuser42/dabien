#!/bin/bash
#desktop=xfce
desktop=$1-citrix
desktop=gnome-citrix
dpkg -l cryptsetup 1>/dev/null 2>/dev/null || (echo cryptsetup not installed && exit -1)
dpkg -l grub-efi-amd64 1>/dev/null 2>/dev/null || (echo grub-efi-amd64 not installed && exit -1)
dpkg -l live-build 1>/dev/null 2>/dev/null || (echo live-build not installed && exit -1)
mkdir -p /liveimages-c/dabienkey
cd /liveimages-c/dabienkey
mkdir -p $desktop
cd $desktop/
lb clean --binary
lb config --distribution bullseye
lb config -a amd64 --parent-archive-areas "main contrib non-free" --archive-areas "main contrib non-free" --bootappend-live "boot=live components locales=en_US.UTF-8,da_DK.UTF-8 keyboard-layouts=dk,us" --security true --debian-installer live
echo '! Packages Priority standard' > config/package-lists/standard.list.chroot
case $desktop in
gnome-citrix)
  echo task-gnome-desktop > config/package-lists/desktop.list.chroot
  ;;
kde-citrix)  
  echo task-kde-desktop >> config/package-lists/desktop.list.chroot
  ;;
cinnamon-citrix)  
  echo task-cinnamon-desktop  >> config/package-lists/desktop.list.chroot
  ;;
lxde-citrix)  
  echo task-lxde-desktop >> config/package-lists/desktop.list.chroot
  ;;
budgie-citrix)  
  echo budgie-desktop  >> config/package-lists/desktop.list.chroot
  ;;
xfce-citrix)  
  echo task-xfce-desktop  >> config/package-lists/desktop.list.chroot
  ;;
*)
  echo task-mate-desktop  > config/package-lists/desktop.list.chroot
  ;;
esac  

echo firmware-misc-nonfree >> config/package-lists/installer.list.chroot
echo gparted >> config/package-lists/installer.list.chroot
echo rsync net-tools cryptsetup  >> config/package-lists/installer.list.chroot
echo git ufw gufw >> config/package-lists/installer.list.chroot
echo vlc x264 >> config/package-lists/installer.list.chroot
echo broadcom-sta-dkms >> config/package-lists/installer.list.chroot
echo live-build >> config/package-lists/installer.list.chroot
echo cups >> config/package-lists/installer.list.chroot
echo tigervnc-viewer tigervnc-standalone-server >> config/package-lists/installer.list.chroot
echo network-manager-openconnect-gnome openconnect >> config/package-lists/installer.list.chroot
echo yad >> config/package-lists/installer.list.chroot
echo gthumb >> config/package-lists/installer.list.chroot
echo libcurl4  libgconf-2-4 libssl1.1 >> config/package-lists/installer.list.chroot
echo zenity xterm syslinux >> config/package-lists/installer.list.chroot
echo zenity xterm syslinux grub-efi-amd64 >> config/package-lists/installer.list.chroot
echo rsync live-build net-tools cryptsetup ecryptfs-utils >> config/package-lists/installer.list.chroot
echo meld vim-gtk3 emacs  >> config/package-lists/installer.list.chroot
lb config --bootappend-live "boot=live components persistence persistence-encryption=luks locales=en_US.UTF-8,da_DK.UTF-8 keyboard-layouts=us,dk "
wget --no-check-certificate -O skel.tgz https://wwvaldemar.dk/misc/citrix-202202-home-overlay.tgz
mkdir -p config/packages.chroot
wget --no-check-certificate -O config/packages.chroot/icaclient_22.2.0.20_amd64.deb https://wwvaldemar.dk/misc/icaclient_22.2.0.20_amd64.deb
mkdir -p /tmp/untar/etc/skel
tar -C /tmp/untar/etc/skel -xvzf skel.tgz
rm -rf config/includes.chroot/*
mkdir -p config/includes.chroot 
cp -rT /tmp/untar config/includes.chroot
wget --no-check-certificate -O skel.tgz https://wwvaldemar.dk/misc/ubuntuwin10ize.tgz
tar -C /tmp/untar/ -xvzf skel.tgz
mkdir -p config/hooks/live
cat <<EOF >config/hooks/live/99-fixnetboot.sh.hook.binary
#!/bin/sh
wget --no-check-certificate https://pubdoc.kitenet.com/~chen/bootdebianB_3.tgz
tar -xvzf bootdebianB_3.tgz 
uniqueid=`date +%Y%m%d%H%M%S`
sed -i.bak "s# Live boot#\nmenuentry 'Debian 11 latest ' {\n  linux '/bootdebianB_3/isolinux/vmlinuz' 'rootovl' 'root=10.100.2.225:/debian_netboot/dBlatest:vers=4,nconnect=10,hard,ro' nfs.nfs4_unique_id=id$uniqueid 'initrd=netinitrd.img' 'ip=dhcp' 'rd.net.dhcp.retry=20' 'BOOT_IMAGE=vmlinuz' splash quiet nouveau.modeset=0\n  initrd '/bootdebianB_3/isolinux/netinitrd.img'\n}\n\# Live boot#" boot/grub/grub.cfg
sed -i.bak "s#set default=0#set default=0\nset timeout=5#" boot/grub/config.cfg
wget -O isolinux/splash.png --no-check-certificate https://pubdoc.kitenet.com/~chen/oticon_splash.png
wget -O boot/grub/splash.png --no-check-certificate https://pubdoc.kitenet.com/~chen/oticon_splash.png
EOF
cat <<EOF >config/hooks/live/99-usermod.sh.hook.chroot
#!/bin/sh
usermod -u 950 citrixlog
groupmod -g 950 citrixlog
cp /etc/ssl/certs/USERTrust_RSA_Certification_Authority.pem  /opt/Citrix/ICAClient/keystore/cacerts
#usermod -u 1000 live
EOF
chmod +rx config/hooks/live/99*
mkdir -p config/includes.chroot/etc/cryptsetup-initramfs
cat <<EOF >config/includes.chroot/etc/cryptsetup-initramfs/conf-hook 
CRYPTSETUP=y
EOF
#kommenter ud hvis du skal pille her med apt-get eller andet
#bash
lb config -b iso --initramfs live-boot
#lb config -b hdd --initramfs live-boot
#lb config --binary-filesystem=ext4 -b hdd --initramfs live-boot
mkdir -p config/includes.chroot/usr/share/applications 
lb build --verbose --debug | tee build.log
if [ -f "live-image-amd64.hybrid.iso" ]; then
	isoname=dabien-${desktop}-amd64-$(date "+%Y%m%d").iso
	mv live-image-amd64.hybrid.iso ${isoname}
	mv live-image-amd64.packages ${isoname}.packages.txt
	shasum ${isoname} binary/live/* >${isoname}.shasum
fi
exit 0
