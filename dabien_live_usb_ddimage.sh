#!/bin/bash

if [[ ${EUID} -ne 0 ]]; then
  echo "this script must be executed with as root"
  exit 1
fi

dev=`losetup -f`
[ "$dev" == "" ] && zenity --info --text "Device not found - exitting " && exit 1

zenity --title "Clone everything?"  --question --text "Clone everything including the personal data and installed programs?" && cloneeverything=1
if [ ! -z "${cloneeverything}" ] ; then
  mounted_presistence_dir=`mount |grep /lib/live/mount/persistence/ | awk '{print $3}'`	
  if [ ! -d "${mounted_presistence_dir}/rw" ]; then
    zenity --title "ERROR - persistence not found"  --question --text "Cannot lookup ${mounted_presistence_dir}/rw"
    exit 1
  fi
  zenity --info --text "Cloning everything" --timeout 2
else
  zenity --info --text "Cloning only the key" --timeout 2
fi


echo "unmounting old partitions"
umount ${dev}p*

lsblk ${dev}

zenity --title "Approve USB key device"  --question --text "This nukes data on ${dev} - continue?" || exit 0

(

echo "5" ; sleep 1
echo "# Making usbkey4GB.dd - takes time..." ; sleep 1
dd if=/dev/zero of=usbkey4GB.dd bs=4M count=1000 
sync
losetup ${dev} usbkey4GB.dd 
if [[ -z "${dev}" || ! -b ${dev} ]]; then
  echo "param 2 must be target block device"
  zenity --title "Problem"  --info  --text "Device $dev must be a bock device" 
  exit 1
fi
echo "15" ; sleep 1
echo "# Creating partitions..." ; sleep 1
parted ${dev} --script mktable gpt
parted ${dev} --script mkpart EFI fat16 1MiB 10MiB
parted ${dev} --script mkpart live fat16 10MiB 2500MB
parted ${dev} --script mkpart persistence ext4 2500MB 100%
parted ${dev} --script set 1 msftdata on
parted ${dev} --script set 2 legacy_boot on
parted ${dev} --script set 2 msftdata on
echo "20" ; sleep 5
echo "# Syncing and probing new partitions"
sync
partprobe
echo "30" ; sleep 6
echo "# Creating file systems"
echo mkfs.vfat -n EFI ${dev}p1
mkfs.vfat -n EFI ${dev}p1
echo mkfs.vfat -n LIVE ${dev}p2
mkfs.vfat -n LIVE ${dev}p2
zenity --title 'Action needed' --info --text 'Please click OK and enter passphrase in terminal when asked!'
xterm -T "Encrypting USB partition - insert passphrase" -e "cryptsetup luksFormat ${dev}p3 " && xterm -T "Opening newly encrypted partition" -e "cryptsetup open ${dev}p3 dev3" && mkfs.ext4 -F -L persistence /dev/mapper/dev3  && sync
sleep 3
partprobe
echo "50" ; sleep 1
echo "# Creating temporary mount locations"
tmp=$(mktemp --tmpdir --directory debianlive.XXXXX)
tmpefi=${tmp}/efi
tmplive=${tmp}/live
tmppersistence=${tmp}/persistence
tmpiso=/lib/live/mount/medium/
tmpall="${tmpefi} ${tmplive} ${tmppersistence} "
echo "60" ; sleep 1
echo "# Mounting resources"
echo mkdir ${tmpall}
mkdir ${tmpall}
echo mount ${dev}p1 ${tmpefi}
mount ${dev}p1 ${tmpefi}
echo mount ${dev}p2 ${tmplive}
mount ${dev}p2 ${tmplive}
echo mount /dev/mapper/dev3 ${tmppersistence}
mount /dev/mapper/dev3 ${tmppersistence}
#echo mount -oro ${iso} ${tmpiso}
#mount -oro ${iso} ${tmpiso}
echo "70" ; sleep 1
echo "# Copying iso image filesystem contents"
cp -ar ${tmpiso}/* ${tmplive}
sync
echo "75" ; sleep 1
echo "# Creating persistence.conf"
if [ ! -z "${cloneeverything}" ] && [ -d "${mounted_presistence_dir}/rw" ] && [ -d "${tmppersistence}/" ] ; then
  echo "77" ; sleep 1
  echo "# Syncing ${mounted_presistence_dir}/ to ${tmppersistence}/ ..."
  rsync -avH --delete ${mounted_presistence_dir}/ ${tmppersistence}/ --exclude "usbkey*.dd"
else
  echo "/ union" > ${tmppersistence}/persistence.conf
fi
echo "80" ; sleep 1
echo "# Installing UEFI grub"
echo grub-install --removable --target=x86_64-efi --boot-directory=${tmplive}/boot/ --efi-directory=${tmpefi} ${dev}
grub-install --removable --target=x86_64-efi --boot-directory=${tmplive}/boot/ --efi-directory=${tmpefi} ${dev}
echo "85" ; sleep 1
echo "# Installing syslinux"
dd bs=440 count=1 conv=notrunc if=/usr/lib/syslinux/mbr/gptmbr.bin of=${dev}
syslinux --install ${dev}p2
echo "85" ; sleep 1
echo "# Fixing isolinux folder/files"
mv ${tmplive}/isolinux ${tmplive}/syslinux
mv ${tmplive}/syslinux/isolinux.bin ${tmplive}/syslinux/syslinux.bin
mv ${tmplive}/syslinux/isolinux.cfg ${tmplive}/syslinux/syslinux.cfg
cp  -a splash.dabien.png ${tmplive}/syslinux/splash.png
cp  -a live.dabien.cfg ${tmplive}/syslinux/live.cfg
echo "87" ; sleep 1
echo "# Fixing grub "
sed --in-place 's#isolinux/splash#syslinux/splash#' ${tmplive}/boot/grub/grub.cfg
sed --in-place 's#isolinux/splash#syslinux/splash#' ${tmplive}/boot/grub/live-theme/theme.txt
#echo "configuring persistence kernel parameter"
sed --in-place '0,/boot=live/{s/\(boot=live .*\)$/\1 persistence/}' ${tmplive}/boot/grub/grub.cfg ${tmplive}/syslinux/menu.cfg
#echo "configuring default keyboard layout (german) and locales (primary en_US, secondary de_DE)"
sed --in-place '0,/boot=live/{s/\(boot=live .*\)$/\1 keyboard-layouts=da locales=da_DK.UTF-8,en_US.UTF-8/}' ${tmplive}/boot/grub/grub.cfg ${tmplive}/syslinux/live.cfg
echo "90" ; sleep 1
echo "# Cleaning up"
umount ${tmpall}
umount ${tmppersistence}
cryptsetup close dev3
rmdir ${tmpall} ${tmp}
echo "95" ; sleep 1
echo "# Sync'ing so that cached writes to USB stick are written"
sync
echo "100" ; sleep 1
echo "#USB stick image is ready" 
) |
zenity --progress --title "Making USB key image" \
--text "Creating partitions..." --percentage=0 || exit 1
exit 0



