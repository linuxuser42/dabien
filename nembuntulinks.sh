#!/bin/bash
mappe=$HOME/Dokumenter/nembuntumappe
mkdir -p $mappe
mkdir -p ~/.local/share/applications/

#https://www.e-boks.dk
wget https://private.e-boks.com/media/up3fb4jb/favicon-48x48.svg -O $mappe/ebox.dk.svg

cat << EOF > ~/.local/share/applications/e-box.dk.desktop
[Desktop Entry]
Name=e-box.dk \n Mail fra offentlige
Comment=Dine ebox mails fra det offentlige og banken
Exec=xdg-open https://www.e-boks.dk
Icon=${mappe}/ebox.dk.svg
Type=Application
Keywords=mail;dansk;dk;nem;nembuntu;
EOF


#https://www.sundhed.dk/
wget  www.sundhed.dk/public/images/favicon-32x32.png -O $mappe/sundhed.dk.png
cat << EOF > ~/.local/share/applications/sundhed.dk.desktop
[Desktop Entry]
Name=Sundhed.dk
Comment=Check dine sundheds data
Exec=xdg-open https://www.sundhed.dk
Icon=${mappe}/sundhed.dk.png
Type=Application
Keywords=sundhed;doktor;sygehus;hospital;medicin;nembuntu
EOF

#https://www.borger.dk
wget https://www.borger.dk/-/media/Borger/Logo/borgerdkLogobbb.ashx -O $mappe/borger.dk.png
cat << EOF > ~/.local/share/applications/borger.dk.desktop
[Desktop Entry]
Name=Borger.dk \n Kommunen
Comment=Gå på borger.dk og kontakt kommunen
Exec=xdg-open https://www.borger.dk
Icon=$mappe/borger.dk.png
Type=Application
Keywords=borger;dansk;dk;nem;nembuntu
EOF

#https://www.skat.dk
wget https://skat.dk/favicon/apple-touch-icon.png -O $mappe/skat.png
cat << EOF > ~/.local/share/applications/skat.dk.desktop
[Desktop Entry]
Name=Skat.dk
Comment=Check din skat
Exec=xdg-open https://www.borger.dk
Icon=$mappe/skat.png
Type=Application
Keywords=skat;dansk;dk;nem;nembuntu
EOF

#https://http://politiken.dk/
wget view-source:https://politiken.dk/assets/icons/favicons/favicon-96x96.png -O $mappe/pol.png
cat << EOF > ~/.local/share/applications/politiken.dk.desktop
[Desktop Entry]
Name=Politiken.dk
Comment=Politikens hjemmeside
Exec=xdg-open https://politiken.dk
Icon=$mappe/pol.png
Type=Application
Keywords=avis;nyheder;dansk;dk;nem;nembuntu
EOF

#https://www.information.dk
wget https://www.information.dk/sites/all/themes/kashmir/images/logo_300.png -O $mappe/inf.png
cat << EOF > ~/.local/share/applications/information.dk.desktop
[Desktop Entry]
Name=Information.dk
Comment=Avisen Information
Exec=xdg-open https://www.information.dk
Icon=$mappe/inf.png
Type=Application
Keywords=avis;information;nyheder;dansk;dk;nem;nembuntu;
EOF

wget https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/Spotify_logo_with_text.svg/320px-Spotify_logo_with_text.svg.png -O $mappe/spotify.svg
cat << EOF > ~/.local/share/applications/spotify.desktop
[Desktop Entry]
Name=Spotify
Comment=Spotify web
Exec=xdg-open https://www.spotify.com/dk/redirect/webplayerlink
Icon=$mappe/spotify.svg
Type=Application
Keywords=musik;musikafspiller;stream;nem;nembuntu;
EOF

wget https://prod95-static.dr-massive.com/favicon.ico -O $mappe/dr.ico
cat << EOF > ~/.local/share/applications/dr1.desktop
[Desktop Entry]
Name=DRTV
Comment=DR TV
Exec=xdg-open https://dr.dk/drtv
Icon=$mappe/dr.ico
Type=Application
Keywords=tv;dr;stream;nem;nembuntu;
EOF

wget https://www.dr.dk/lyd/_img/drlyd-sharing-image.png -O $mappe/drlyd.png
cat << EOF > ~/.local/share/applications/dr1.desktop
[Desktop Entry]
Name=DR LYD
Comment=DR LYD
Exec=xdg-open https://www.dr.dk/lyd
Icon=$mappe/drlyd.png
Type=Application
Keywords=tv;dr;stream;nem;nembuntu;
EOF

wget https://upload.wikimedia.org/wikipedia/en/thumb/d/d7/DR_P1_logo_2020.svg/200px-DR_P1_logo_2020.svg.png  -O $mappe/dradio-p1.png
cat << EOF > ~/.local/share/applications/dr-p1.desktop
[Desktop Entry]
Name=P1
Comment=DR P1
Exec=vlc http://live-icy.gss.dr.dk/A/A03H.mp3.m3u
Icon=$mappe/dradio-p1.png
Type=Application
Keywords=radio;p1;dr;stream;nem;nembuntu;
EOF

wget https://upload.wikimedia.org/wikipedia/en/thumb/c/c3/DR_P2_logo_2020.svg/200px-DR_P2_logo_2020.svg.png -O $mappe/dradio-p2.png

cat << EOF > ~/.local/share/applications/dr-p2.desktop
[Desktop Entry]
Name=P2
Comment=DR P2
Exec=vlc http://live-icy.gss.dr.dk/A/A04H.mp3.m3u
Icon=$mappe/dradio-p2.png
Type=Application
Keywords=radio;p2;dr;stream;nem;nembuntu;
EOF

wget https://upload.wikimedia.org/wikipedia/en/thumb/c/c4/DR_P3_logo_2020.svg/190px-DR_P3_logo_2020.svg.png -O $mappe/dradio-p3.png
cat << EOF > ~/.local/share/applications/dr-p3.desktop
[Desktop Entry]
Name=P3
Comment=DR P3
Exec=vlc http://live-icy.gss.dr.dk/A/A05H.mp3.m3u
Icon=$mappe/dradio-p3.png
Type=Application
Keywords=radio;p3;dr;stream;nem;nembuntu;
EOF

wget https://upload.wikimedia.org/wikipedia/en/thumb/d/da/DR_P4_logo_2020.svg/200px-DR_P4_logo_2020.svg.png -O $mappe/dradio-p4.png
cat << EOF > ~/.local/share/applications/dr-p4-københavn.desktop
[Desktop Entry]
Name=P4 Kbh
Comment=DR P4 Kbh
Exec=vlc http://live-icy.gss.dr.dk/A/A08H.mp3.m3u
Icon=$mappe/dradio-p4.png
Type=Application
Keywords=radio;p4;dr;stream;nem;nembuntu;
EOF

for i in ~/.local/share/applications/*.desktop; do 
  chmod a+rx $i
  rsync -a $i $(xdg-user-dir DESKTOP)
done

