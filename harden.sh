#!/bin/bash
# does everything from securityfixes - except disks fix
echo hardening ongoing
sudo passwd user
sudo /home/user/dabien/ufw_firewall.sh
sudo apt-get -y remove live-config-systemd  
sudo sed -i 's/AutomaticLogin/#AutomaticLogin/g' /etc/gdm3/daemon.conf && sudo sed -i 's/TimedLogin/#TimedLogin/g' /etc/gdm3/daemon.conf
sudo sed -i 's#NOPASSWD#PASSWD#g' /etc/sudoers.d/live
echo hardening done

