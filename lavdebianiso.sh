desktop=gnome
dpkg -l cryptsetup 1>/dev/null 2>/dev/null || (echo cryptsetup not installed && exit -1)
dpkg -l grub-efi-amd64 1>/dev/null 2>/dev/null || (echo grub-efi-amd64 not installed && exit -1)
dpkg -l live-build 1>/dev/null 2>/dev/null || (echo live-build not installed && exit -1)
mkdir -p /liveimages/dabienkey
cd /liveimages/dabienkey
mkdir -p $desktop
cd $desktop/
lb clean --binary
lb config -a amd64 --archive-areas "main contrib non-free" --bootappend-live "boot=live components locales=da_DK.UTF-8 keyboard-layouts=dk" --security true --debian-installer live
echo '! Packages Priority standard' > config/package-lists/standard.list.chroot
case $desktop in
gnome)
  echo task-gnome-desktop task-danish task-danish-desktop > config/package-lists/desktop.list.chroot
  ;;
kde)  
  echo task-kde-desktop task-danish-kde-desktop task-danish task-danish-desktop >> config/package-lists/desktop.list.chroot
  ;;
cinnamon)  
  echo task-cinnamon-desktop task-danish task-danish-desktop >> config/package-lists/desktop.list.chroot
  ;;
lxde)  
  echo task-lxde-desktop task-danish task-danish-desktop >> config/package-lists/desktop.list.chroot
  ;;
budgie)  
  echo budgie-desktop task-danish task-danish-desktop >> config/package-lists/desktop.list.chroot
  ;;
xfce)  
  echo task-xfce-desktop task-danish task-danish-desktop >> config/package-lists/desktop.list.chroot
  ;;
*)
  echo task-gnome-desktop task-danish task-danish-desktop > config/package-lists/desktop.list.chroot
  ;;
esac  

echo debian-installer-launcher > config/package-lists/installer.list.chroot
echo myspell-da myspell-de-de myspell-fr myspell-es myspell-it myspell-sv-se myspell-nb myspell-ca myspell-fo myspell-et myspell-lt myspell-lv myspell-nn  myspell-ru >> config/package-lists/installer.list.chroot
echo keepassx >> config/package-lists/installer.list.chroot
echo vlc x264 >> config/package-lists/installer.list.chroot
echo cups >> config/package-lists/installer.list.chroot
echo broadcom-sta-dkms >> config/package-lists/installer.list.chroot
echo audacity geogebra-gnome geogebra >> config/package-lists/installer.list.chroot
echo libreoffice-l10n-da libreoffice-help-da >> config/package-lists/installer.list.chroot
echo network-manager-openconnect-gnome openconnect >> config/package-lists/installer.list.chroot
echo frozen-bubble >> config/package-lists/installer.list.chroot
echo yad >> config/package-lists/installer.list.chroot
echo snapd >> config/package-lists/installer.list.chroot
echo iceweasel-l10n-da icedove icedove-l10n-da >> config/package-lists/installer.list.chroot
echo x2goclient >> config/package-lists/installer.list.chroot
echo gparted >> config/package-lists/installer.list.chroot
echo kodi >> config/package-lists/installer.list.chroot
echo chromium chromium-l10n >> config/package-lists/installer.list.chroot
echo iceowl-extension >> config/package-lists/installer.list.chroot
echo clonezilla >> config/package-lists/installer.list.chroot
echo gksu rsync rsnapshot net-tools cryptsetup ecryptfs-utils >> config/package-lists/installer.list.chroot
echo octave-control octave-image octave-io octave-optim octave-signal octave-statistics  >> config/package-lists/installer.list.chroot
echo meld vim-gnome emacs  >> config/package-lists/installer.list.chroot
echo python-mathgl eclipse-pydev  >> config/package-lists/installer.list.chroot
echo gthumb >> config/package-lists/installer.list.chroot
echo libcurl3  libgconf-2-4 libssl1.0.2 >> config/package-lists/installer.list.chroot
echo evolution-ews pidgin pidgin-sipe tigervnc-viewer >> config/package-lists/installer.list.chroot
echo grub-efi-amd64 >> config/package-lists/installer.list.chroot
echo git ufw >> config/package-lists/installer.list.chroot
lb config --bootappend-live "boot=live components persistence persistence-encryption=luks locales=da_DK.UTF-8 keyboard-layouts=dk "
rm -rf config/includes.chroot/*
if [ "$desktop" == "gnome" ]; then
# new mac'ish desktop 
  wget --no-check-certificate -O skel.tgz https://github.com/linuxuser42/dabien/raw/master/debian9osx-skel.tgz
  wget --no-check-certificate -O dabienscripts.tgz https://github.com/linuxuser42/dabien/raw/master/dabienscripts.tgz
  mkdir -p /tmp/untar
  mkdir -p /tmp/untar2
  tar -C /tmp/untar -xvzf skel.tgz
  tar -C /tmp/untar2 -xvzf dabienscripts.tgz
  rm -f skel.tgz dabienscripts.tgz
fi
mkdir -p config/includes.chroot 
cp -rT /tmp/untar config/includes.chroot
cp -rT /tmp/untar2/home/user config/includes.chroot/etc/skel
mkdir -p config/includes.chroot/usr/share/applications 
cp -rT /tmp/untar2/usr/share/applications config/includes.chroot/usr/share/applications 
lb build
if [ -f "live-image-amd64.hybrid.iso" ]; then
	isoname=dabien-${desktop}-amd64-$(date "+%Y%m%d").iso
	mv live-image-amd64.hybrid.iso ${isoname}
	mv live-image-amd64.packages ${isoname}.packages.txt
	shasum ${isoname} binary/live/* >${isoname}.shasum
fi
exit 0
