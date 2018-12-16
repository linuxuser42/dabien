#!/bin/bash

if [[ ${EUID} -ne 0 ]]; then
  echo "this script must be executed with as root"
  exit 1
fi

iso=$1

zenity --title 'Action needed' --info --text "Pull-out target USB key and click OK and wait"  
sleep 5
cat /proc/partitions >/tmp/parts1
zenity --title 'Action needed' --info --text 'Plug-in target USB key and click OK and wait' 
sleep 10
cat /proc/partitions >/tmp/parts2
[ "$2" == "" ] && dev=`diff /tmp/parts1 /tmp/parts2 | awk '/([a-z]+)$/{print "/dev/" $5}'`
rm /tmp/parts1 /tmp/parts2
[ "$dev" == "" ] && zenity --info --text "Device not found - exitting " && exit 1

usbfdisk=`fdisk -l $dev | head -1`
zenity --title "Approve USB key device"  --question --text "Scanned device set to $dev - $usbfdisk - continue?" || exit 0




if [[ -z "${dev}" || ! -b ${dev} ]]; then
  echo "param 2 must be target block device"
  zenity --title "Problem"  --info  --text "Device $dev must be a bock device" 
  exit 1
fi

if [[ "${dev}" =~ ^.*[0-9]$ ]]; then
  zenity --title "Problem"  --info  --text "Device $dev must not end with digit" 
  exit 1
fi

echo "unmounting old partitions"
umount ${dev}*

lsblk ${dev}

zenity --title "Approve USB key device"  --question --text "This nukes data on ${dev} - continue?" || exit 0

(
echo "10" ; sleep 1
echo "# Creating partitions..." ; sleep 1
parted ${dev} --script mktable gpt
parted ${dev} --script mkpart EFI fat16 1MiB 10MiB
parted ${dev} --script mkpart live fat16 10MiB 3GiB
parted ${dev} --script mkpart persistence ext4 3GiB 100%
parted ${dev} --script set 1 msftdata on
parted ${dev} --script set 2 legacy_boot on
parted ${dev} --script set 2 msftdata on
echo "20" ; sleep 5
echo "# Syncing and probing new partitions"
sync
partprobe
echo "30" ; sleep 6
echo "# Creating file systems"
echo mkfs.vfat -n EFI ${dev}1
mkfs.vfat -n EFI ${dev}1
echo mkfs.vfat -n LIVE ${dev}2
mkfs.vfat -n LIVE ${dev}2
zenity --title 'Action needed' --info --text 'Please click OK and enter passphrase in terminal when asked!'
xterm -T "Encrypting USB partition - insert passphrase" -e "cryptsetup luksFormat ${dev}3 " && xterm -T "Opening newly encrypted partition" -e "cryptsetup open ${dev}3 dev3" && mkfs.ext4 -F -L persistence /dev/mapper/dev3  && sync
sleep 3
partprobe
echo "50" ; sleep 1
echo "# Creating temporary mount locations"
tmp=$(mktemp --tmpdir --directory debianlive.XXXXX)
tmpefi=${tmp}/efi
tmplive=${tmp}/live
tmppersistence=${tmp}/persistence
tmpiso=${tmp}/iso
tmpall="${tmpefi} ${tmplive} ${tmppersistence} ${tmpiso}"
echo "60" ; sleep 1
echo "# Mounting resources"
echo mkdir ${tmpall}
mkdir ${tmpall}
echo mount ${dev}1 ${tmpefi}
mount ${dev}1 ${tmpefi}
echo mount ${dev}2 ${tmplive}
mount ${dev}2 ${tmplive}
echo mount /dev/mapper/dev3 ${tmppersistence}
mount /dev/mapper/dev3 ${tmppersistence}
echo mount -oro ${iso} ${tmpiso}
mount -oro ${iso} ${tmpiso}
echo "70" ; sleep 1
echo "# Copying iso image filesystem contents"
cp -ar ${tmpiso}/* ${tmplive}
sync
echo "75" ; sleep 1
echo "# Creating persistence.conf"
echo "/ union" > ${tmppersistence}/persistence.conf
echo "80" ; sleep 1
echo "# Installing UEFI grub"
echo grub-install --removable --target=x86_64-efi --boot-directory=${tmplive}/boot/ --efi-directory=${tmpefi} ${dev}
grub-install --removable --target=x86_64-efi --boot-directory=${tmplive}/boot/ --efi-directory=${tmpefi} ${dev}
echo "85" ; sleep 1
echo "# Installing syslinux"
dd bs=440 count=1 conv=notrunc if=/usr/lib/syslinux/mbr/gptmbr.bin of=${dev}
syslinux --install ${dev}2
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
echo "#USB stick is ready" 
) |
zenity --progress --title "Making USB key" \
--text "Creating partitions..." --percentage=0 || exit 1
exit 0



