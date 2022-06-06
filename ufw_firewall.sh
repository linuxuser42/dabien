#!/bin/bash
# installing ufw firewall 
dpkg -l  | grep ufw || sudo apt-get install ufw >/dev/null
sudo ufw --force reset
sudo ufw default deny outgoing
sudo ufw default deny incoming
sudo ufw allow out 80
sudo ufw allow out 443
sudo ufw allow out 22
sudo ufw allow out 222
sudo ufw allow out 123 
sudo ufw allow out 2222
sudo ufw allow out 1900
sudo ufw allow out 1400
sudo ufw allow 30000:65000/udp
sudo ufw allow 30000:65000/tcp
sudo ufw allow out 5900:6000/tcp
sudo ufw allow out 5900:6000/udp
sudo ufw allow out 5353/udp
sudo ufw allow out 5353/tcp
sudo ufw allow out 5061/tcp
sudo ufw allow out 3389/tcp
sudo ufw allow out 9100/tcp
sudo ufw allow out 10000/tcp
sudo ufw allow out 53/tcp
sudo ufw allow out 53/udp
#sudo ufw allow out dns
sudo service ufw start
sudo ufw disable
sudo ufw enable
sudo ufw status
sudo service ufw status |grep active



