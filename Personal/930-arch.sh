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

if [ ! -f /etc/dev-rel ] ; then 

	if grep -q "Arch Linux" /etc/os-release; then

		echo
		tput setaf 2
		echo "########################################################################"
		echo "################### We are on ARCH LINUX"
		echo "########################################################################"
		tput sgr0
		
		echo
		echo "Adding font to /etc/vconsole.conf"

		echo
		if ! grep -q "FONT=lat4-19" /etc/vconsole.conf; then
		echo '
FONT=lat4-19' | sudo tee --append /etc/vconsole.conf
		fi

		# have aliases when in arch-chroot
		sudo cp -arf /etc/skel/. /root

		echo
		tput setaf 6
		echo "########################################################################"
		echo "################### Done"
		echo "########################################################################"
		tput sgr0
		echo

	fi

fi

echo
tput setaf 6
echo "##############################################################"
echo "###################  $(basename $0) done"
echo "##############################################################"
tput sgr0
echo