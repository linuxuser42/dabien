#!/bin/bash

if [[ ${EUID} -ne 0 ]]; then
  echo "this script must be executed with as root"
  exit 1
fi

#iso=$1

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
parted ${dev} --script mkpart live fat32 10MiB 3GiB
parted ${dev} --script mkpart persistence ext4 3GiB 100%
parted ${dev} --script set 1 msftdata on
echo "20" ; sleep 5
echo "# Syncing and probing new partitions"
sync
partprobe
echo "30" ; sleep 6
echo "# Creating file systems"
echo mkfs.vfat -n LIVE ${dev}1
mkfs.vfat -n LIVE ${dev}1
zenity --title 'Action needed' --info --text 'Please click OK and enter passphrase in terminal when asked!'
xterm -T "Encrypting USB partition - insert passphrase" -e "cryptsetup luksFormat ${dev}2 " && xterm -T "Opening newly encrypted partition" -e "cryptsetup open ${dev}2 dev2" && mkfs.ext4 -F -L persistence /dev/mapper/dev2  && sync
sleep 3
partprobe
echo "50" ; sleep 1
echo "# Creating temporary mount locations"
tmp=$(mktemp --tmpdir --directory debianlive.XXXXX)
tmplive=${tmp}/live
tmppersistence=${tmp}/persistence
tmpiso=/lib/live/mount/medium/
tmpall="${tmplive} ${tmppersistence} "
echo "60" ; sleep 1
echo "# Mounting resources"
echo mkdir ${tmpall}
mkdir ${tmpall}
echo mount ${dev}1 ${tmplive}
mount ${dev}1 ${tmplive}
echo mount /dev/mapper/dev2 ${tmppersistence}
mount /dev/mapper/dev2 ${tmppersistence}
#echo mount -oro ${iso} ${tmpiso}
#mount -oro ${iso} ${tmpiso}
echo "70" ; sleep 1
echo "# Copying iso image filesystem contents"
rsync -avH ${tmpiso}/ ${tmplive}/
sync
echo "75" ; sleep 1
echo "# Creating persistence.conf"
if [ ! -z "${cloneeverything}" ] && [ -d "${mounted_presistence_dir}/rw" ] && [ -d "${tmppersistence}/" ] ; then
  echo "77" ; sleep 1
  echo "# Syncing ${mounted_presistence_dir}/ to ${tmppersistence}/ ..."
  rsync -avH --delete ${mounted_presistence_dir}/ ${tmppersistence}/
else
  echo "/ union" > ${tmppersistence}/persistence.conf
fi
echo "85" ; sleep 1
echo "# Cleaning up"
umount ${tmpall}
umount ${tmppersistence}
cryptsetup close dev2
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



