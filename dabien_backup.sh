(
echo "50" ; sleep 1
echo "#Backing up ..." 
rsnapshot alpha || zenity --title 'Problem' --timeout=2 --info --text 'Extra Dabien key not mounted?' && exit 1
echo "60" ; sync
echo "100" ;  sleep 1
echo "#Backup done" 
) |
zenity --progress --title "Backing up home data " \
	--text "Running rsnapshot" --percentage=0 --timeout=2 || exit 1

