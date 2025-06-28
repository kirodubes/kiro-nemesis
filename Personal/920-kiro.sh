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
echo "################### FOR KIRO"
echo "########################################################################"
tput sgr0
echo

echo
echo "Adding nanorc settings"
echo

if [ -f /etc/nanorc ]; then
    sudo cp $installed_dir/settings/nano/nanorc /etc/nanorc
fi

echo
echo "Enable fstrim timer"
sudo systemctl enable fstrim.timer

echo
echo "Testing if qemu agent is still active"
result=$(systemd-detect-virt)
echo "Systemd-detect-virt = "
test=$(systemctl is-enabled qemu-guest-agent.service)
echo "Is qemu guest agent active = "
echo "If one of the parameters is empty you get unary parameter"
echo "Nothing is wrong however"
if [ "$test" == "enabled" ] && { [ "$result" == "none" ] || [ "$result" == "oracle" ]; }; then
    echo
    echo "Disable qemu agent service"
    sudo systemctl disable qemu-guest-agent.service 2>/dev/null
    echo
fi



# personal /etc/pacman.d/gnupg/gpg.conf for Erik Dubois

echo
tput setaf 2
echo "################################################################################"
echo "Copying gpg.conf to /etc/pacman.d/gnupg/gpg.conf"
echo "################################################################################"
tput sgr0
echo
sudo cp -v gpg.conf /etc/pacman.d/gnupg/gpg.conf
echo


echo
tput setaf 6
echo "##############################################################"
echo "###################  $(basename $0) done"
echo "##############################################################"
tput sgr0
echo