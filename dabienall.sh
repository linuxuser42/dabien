#!/bin/bash
rm -rf /liveimages/dabienkey/{gnome,mate,kde,lxde,xfce}	
rm -rf /liveimages-c/dabienkey	
#sh ./dabien.sh gnome
sh ./dabien.sh kde
sh ./dabien.sh lxde
sh ./dabien.sh mate
sh ./dabien.sh xfce
mkdir -p /liveimages/dabienkey/images && cd /liveimages/dabienkey/images && mv ../*/dabien* . && /home/overgaden/makehtml.sh >indexiso.html \
	&& /home/overgaden/doftpliveimages.sh *.iso *.html *.txt *.shasum 
cd /home/overgaden
rm -rf /liveimages/dabienkey/{gnome,mate,kde,lxde,xfce}
rm -rf /liveimages/dabienkey-c/{gnome,mate,kde,lxde,xfce}	
cd /home/overgaden
sh ./dabien-citrix.sh gnome
cd /liveimages/dabienkey/images ; mv /liveimages-c/dabienkey/gnome/dabien* . && /home/overgaden/makehtml.sh >>indexiso.html \
	&& /home/overgaden/doftpliveimages.sh *.iso *.html *.txt *.shasum 
