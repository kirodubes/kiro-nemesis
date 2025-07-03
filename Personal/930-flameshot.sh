#!/bin/bash
#set -e
##################################################################################################################################
# Author    : Erik Dubois
# Website   : https://www.erikdubois.be
# Youtube   : https://youtube.com/erikdubois
##################################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################################
#tput setaf 0 = black
#tput setaf 1 = red
#tput setaf 2 = green
#tput setaf 3 = yellow
#tput setaf 4 = dark blue
#tput setaf 5 = purple
#tput setaf 6 = cyan
#tput setaf 7 = gray
#tput setaf 8 = light blue
##################################################################################################################################

installed_dir=$(dirname $(readlink -f $(basename `pwd`)))

##################################################################################################################################

if [ "$DEBUG" = true ]; then
    echo
    echo "------------------------------------------------------------"
    echo "Running $(basename $0)"
    echo "------------------------------------------------------------"
    echo
    read -n 1 -s -r -p "Debug mode is on. Press any key to continue..."
    echo
fi

##################################################################################################################################

echo
tput setaf 3
echo "########################################################################"
echo "################### Flameshot icon in toolbar chadwm"
echo "########################################################################"
tput sgr0
echo

sudo rm /usr/share/icons/hicolor/scalable/apps/flameshot.svg
sudo rm /usr/share/icons/hicolor/scalable/apps/org.flameshot.Flameshot.svg

sudo rm /usr/share/icons/hicolor/128x128/apps/flameshot.png
sudo rm /usr/share/icons/hicolor/48x48/apps/flameshot.png
sudo rm /usr/share/icons/hicolor/128x128/apps/org.flameshot.Flameshot.png
sudo rm /usr/share/icons/hicolor/48x48/apps/org.flameshot.Flameshot.png

gtk-update-icon-cache -f /usr/share/icons/al-beautyline
gtk-update-icon-cache -f /usr/share/icons/al-candy-icons
gtk-update-icon-cache -f /usr/share/icons/neo-candy-icons

#sudo cp  $installed_dir/settings/flameshot/org.flameshot.Flameshot.svg /usr/share/icons/hicolor/128x128/apps/flameshot.svg
#sudo cp  $installed_dir/settings/flameshot/org.flameshot.Flameshot.svg /usr/share/icons/hicolor/48x48/apps/flameshot.svg
#sudo cp  $installed_dir/settings/flameshot/org.flameshot.Flameshot.svg /usr/share/icons/hicolor/128x128/apps/org.flameshot.Flameshot.png

echo
tput setaf 6
echo "##############################################################"
echo "###################  $(basename $0) done"
echo "##############################################################"
tput sgr0
echo