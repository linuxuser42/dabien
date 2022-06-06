#!/bin/bash
#desktop=xfce
desktop=$1-citrix
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
echo x2goclient x2goserver >> config/package-lists/installer.list.chroot
echo gparted >> config/package-lists/installer.list.chroot
echo rsync net-tools cryptsetup  >> config/package-lists/installer.list.chroot
echo git ufw gufw >> config/package-lists/installer.list.chroot
echo myspell-da myspell-fr myspell-es myspell-sv-se myspell-nb  myspell-fo myspell-et myspell-lv myspell-nn  myspell-ru >> config/package-lists/installer.list.chroot
echo keepassx >> config/package-lists/installer.list.chroot
echo vlc x264 >> config/package-lists/installer.list.chroot
echo cups >> config/package-lists/installer.list.chroot
echo tigervnc-viewer tigervnc-standalone-server >> config/package-lists/installer.list.chroot
echo network-manager-openconnect-gnome openconnect >> config/package-lists/installer.list.chroot
echo chromium chromium-l10n >> config/package-lists/installer.list.chroot
echo meld emacs vim-gtk3  >> config/package-lists/installer.list.chroot
echo yad >> config/package-lists/installer.list.chroot
echo snapd >> config/package-lists/installer.list.chroot
echo gthumb >> config/package-lists/installer.list.chroot
echo libcurl4  libgconf-2-4 libssl1.1 >> config/package-lists/installer.list.chroot
echo zenity xterm syslinux >> config/package-lists/installer.list.chroot
#echo zenity xterm syslinux grub-efi-amd64 >> config/package-lists/installer.list.chroot
echo octave-control octave-image octave-io octave-optim octave-signal octave-statistics octave-arduino audacity >> config/package-lists/installer.list.chroot

#echo rsync rsnapshot net-tools cryptsetup ecryptfs-utils >> config/package-lists/installer.list.chroot
#echo meld vim-gnome emacs  >> config/package-lists/installer.list.chroot
#echo python-mathgl >> config/package-lists/installer.list.chroot
lb config --bootappend-live "boot=live components persistence persistence-encryption=luks locales=da_DK.UTF-8 keyboard-layouts=dk "
wget --no-check-certificate -O skel.tgz https://wwvaldemar.dk/misc/ubuntuwin10ize.tgz
wget --no-check-certificate -O dabien_live_usb.sh https://raw.githubusercontent.com/linuxuser42/dabien/master/dabien_live_usb.sh
mkdir -p config/bootloaders/grub-pc/
wget --no-check-certificate -O config/bootloaders/grub-pc/splash.png https://raw.githubusercontent.com/linuxuser42/dabien/master/splash.dabien.png
rm -rf /tmp/untar
mkdir /tmp/untar
tar -C /tmp/untar/ -xvzf skel.tgz
rm -rf config/includes.chroot/*
mkdir -p config/includes.chroot 
cp -rT /tmp/untar config/includes.chroot
cp dabien_live_usb.sh config/includes.chroot/usr/sbin && chmod +rx config/includes.chroot/usr/sbin/dabien_live_usb.sh
cp -rT /tmp/untar2/home/user config/includes.chroot/etc/skel
mkdir -p config/hooks/live
cat <<EOF >config/hooks/live/99-usermod.sh.hook.chroot
#!/bin/sh
usermod -u 950 citrixlog
groupmod -g 950 citrixlog
cp /etc/ssl/certs/USERTrust_RSA_Certification_Authority.pem  /opt/Citrix/ICAClient/keystore/cacerts
#usermod -u 1000 live
EOF
chmod +rx config/hooks/live/99-usermod.sh.hook.chroot
mkdir -p config/includes.chroot/etc/cryptsetup-initramfs
cat <<EOF >config/includes.chroot/etc/cryptsetup-initramfs/conf-hook 
CRYPTSETUP=y
EOF
#kommenter ud hvis du skal pille her med apt-get eller andet
#bash
lb config --initramfs live-boot
mkdir -p config/includes.chroot/usr/share/applications 
lb build
if [ -f "live-image-amd64.hybrid.iso" ]; then
	isoname=dabien-${desktop}-amd64-$(date "+%Y%m%d").iso
	mv live-image-amd64.hybrid.iso ${isoname}
	mv live-image-amd64.packages ${isoname}.packages.txt
	shasum ${isoname} binary/live/* >${isoname}.shasum
fi
exit 0
