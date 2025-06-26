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

# Check if /etc/dev-rel contains the word 'kiro'
if [ -f /etc/dev-rel ]; then

    if grep -q "kiro" /etc/dev-rel; then
        echo "'kiro' found in /etc/dev-rel. Proceeding with replacement..."

        file="/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"

        if [[ -f "$file" ]]; then
            sudo sed -i 's/ArcoLinux/Kiro/g' "$file"
            echo "Updated: $file"
        else
            echo "File not found: $file"
        fi
    fi
fi

echo
tput setaf 3
echo "########################################################################"
echo "FINAL SKEL"
echo "Copying all files and folders from /etc/skel to ~"
echo "First we make a backup of .config"
echo "Wait for it ...."
echo "########################################################################"
tput sgr0
echo

cp -Rf ~/.config ~/.config-backup-$(date +%Y.%m.%d-%H.%M.%S)
cp -arf /etc/skel/. ~

echo
tput setaf 6
echo "##############################################################"
echo "###################  $(basename $0) done"
echo "##############################################################"
tput sgr0
echo
