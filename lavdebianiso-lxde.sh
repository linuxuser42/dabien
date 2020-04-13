desktop=lxde
dpkg -l cryptsetup 1>/dev/null 2>/dev/null || (echo cryptsetup not installed && exit -1)
dpkg -l grub-efi-amd64 1>/dev/null 2>/dev/null || (echo grub-efi-amd64 not installed && exit -1)
dpkg -l live-build 1>/dev/null 2>/dev/null || (echo live-build not installed && exit -1)
mkdir -p /home/liveimages/dabienkey
cd /home/liveimages/dabienkey
mkdir -p $desktop
cd $desktop/
lb clean --binary
lb config --distribution stretch
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
echo keepassx >> config/package-lists/installer.list.chroot
echo cups >> config/package-lists/installer.list.chroot
echo broadcom-sta-dkms >> config/package-lists/installer.list.chroot
echo openconnect >> config/package-lists/installer.list.chroot
echo yad >> config/package-lists/installer.list.chroot
echo tigervnc-viewer ssvnc x2goclient >> config/package-lists/installer.list.chroot
echo brightside plank xcompmgr >> config/package-lists/installer.list.chroot
echo gparted >> config/package-lists/installer.list.chroot
echo gksu rsync rsnapshot net-tools cryptsetup ecryptfs-utils >> config/package-lists/installer.list.chroot
echo libcurl3  libgconf-2-4 libssl1.0.2 >> config/package-lists/installer.list.chroot
echo grub-efi-amd64 >> config/package-lists/installer.list.chroot
echo git ufw >> config/package-lists/installer.list.chroot
lb config --bootappend-live "boot=live components persistence persistence-encryption=luks locales=da_DK.UTF-8 keyboard-layouts=dk "
rm -rf config/includes.chroot/*
# new mac'ish desktop 
  wget --no-check-certificate -O skel.tgz https://github.com/linuxuser42/dabien/raw/master/debian9osx-skel.tgz
  wget --no-check-certificate -O dabienscripts.tgz https://github.com/linuxuser42/dabien/raw/master/dabienscripts.tgz
  wget --no-check-certificate -O lxde-skel.tgz https://github.com/linuxuser42/dabien/raw/master/lxde-skel.tgz
  mkdir -p /tmp/untar2
  mkdir -p /tmp/untar3
  tar -C /tmp/untar2 -xvzf dabienscripts.tgz
  tar -C /tmp/untar3 -xvzf lxde-skel.tgz
  rm -f dabienscripts.tgz lxde-skel.tgz
mkdir -p config/includes.chroot/etc/skel 
cp -rT /tmp/untar2/home/user config/includes.chroot/etc/skel
cp -rT /tmp/untar3 config/includes.chroot/etc/skel
mkdir -p config/includes.chroot/usr/share/applications 
cp -rT /tmp/untar2/usr/share/applications config/includes.chroot/usr/share/applications 
mkdir -p config/packages.chroot/
wget  https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/skippy-xd/skippy-xd_0.5-1_amd64.deb 
mv skippy-xd_0.5-1_amd64.deb config/packages.chroot
ln -s /usr/share/zoneinfo/Europe/Copenhagen config/includes.chroot/etc/localtime
echo "Europe/Copenhagen" >config/includes.chroot/etc/timezone
lb build
if [ -f "live-image-amd64.hybrid.iso" ]; then
	isoname=dabien-${desktop}-amd64-$(date "+%Y%m%d").iso
	mv live-image-amd64.hybrid.iso ${isoname}
	mv live-image-amd64.packages ${isoname}.packages.txt
	shasum ${isoname} binary/live/* >${isoname}.shasum
fi
exit 0
