(
echo "50" ; sleep 1
echo "#Backing up ..." 
rsync -avH --delete /media/user/persistence/alpha.0/localhost/home/user /home || zenity --title 'Problem' --timeout=2 --info --text 'Restore problem - Extra Dabien key not mounted?' && exit 1
echo "100" ; sleep 1
echo "#Backup done" 
) |
zenity --progress --title "Backing up home data " \
	--text "Running rsnapshot" --percentage=0 --timeout=2 || exit 1

