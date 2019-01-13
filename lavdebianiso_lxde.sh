desktop=lxde
dpkg -l cryptsetup 1>/dev/null 2>/dev/null || (echo cryptsetup not installed && exit -1)
dpkg -l grub-efi-amd64 1>/dev/null 2>/dev/null || (echo grub-efi-amd64 not installed && exit -1)
dpkg -l live-build 1>/dev/null 2>/dev/null || (echo live-build not installed && exit -1)
mkdir -p ~/dabien
cd ~/dabien
mkdir -p $desktop
cd $desktop/
lb clean --binary
lb config -a amd64 --archive-areas "main contrib non-free" --bootappend-live "boot=live components locales=da_DK.UTF-8 keyboard-layouts=dk" --security true --debian-installer live
echo '! Packages Priority standard' > config/package-lists/standard.list.chroot 
echo task-lxde-desktop task-danish task-danish-desktop >> config/package-lists/desktop.list.chroot
echo debian-installer-launcher > config/package-lists/installer.list.chroot
echo broadcom-sta-dkms >> config/package-lists/installer.list.chroot
echo libreoffice-l10n-da libreoffice-help-da >> config/package-lists/installer.list.chroot
echo network-manager-openconnect-gnome openconnect >> config/package-lists/installer.list.chroot
echo frozen-bubble >> config/package-lists/installer.list.chroot
echo yad >> config/package-lists/installer.list.chroot
echo snapd >> config/package-lists/installer.list.chroot
echo tigervnc-viewer x2goclient >> config/package-lists/installer.list.chroot
echo gparted >> config/package-lists/installer.list.chroot
echo gksu rsync rsnapshot net-tools cryptsetup ecryptfs-utils >> config/package-lists/installer.list.chroot
echo libcurl3  libgconf-2-4 libssl1.0.2 >> config/package-lists/installer.list.chroot
echo evolution-ews pidgin pidgin-sipe tigervnc-viewer >> config/package-lists/installer.list.chroot
echo grub-efi-amd64 >> config/package-lists/installer.list.chroot
lb config --bootappend-live "boot=live components persistence persistence-encryption=luks locales=da_DK.UTF-8 keyboard-layouts=dk "
rm -rf config/includes.chroot/*
wget --no-check-certificate -O skel.tgz https://github.com/linuxuser42/dabien/raw/master/debian9osx-skel.tgz
wget --no-check-certificate -O dabienscripts.tgz https://github.com/linuxuser42/dabien/raw/master/dabienscripts.tgz
mkdir -p /tmp/untar
mkdir -p /tmp/untar2
tar -C /tmp/untar -xvzf skel.tgz
tar -C /tmp/untar2 -xvzf dabienscripts.tgz
rm -f skel.tgz dabienscripts.tgz
mkdir -p config/includes.chroot 
cp -rT /tmp/untar config/includes.chroot
cp -rT /tmp/untar2/home/user config/includes.chroot/etc/skel
mkdir -p config/includes.chroot/usr/share/applications 
cp -rT /tmp/untar2/usr/share/applications config/includes.chroot/usr/share/applications 
lb build
exit 0
