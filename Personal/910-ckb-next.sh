#!/bin/bash
set -uo pipefail  # Do not use set -e, we want to continue on error
##################################################################################################################
# Author    : Erik Dubois
# Website   : https://www.erikdubois.be
# Youtube   : https://youtube.com/erikdubois
# Github    : https://github.com/erikdubois
# Github    : https://github.com/kirodubes
# Github    : https://github.com/buildra
# SF        : https://sourceforge.net/projects/kiro/files/
##################################################################################################################
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

#end colors
#tput sgr0
##################################################################################################################################

# Error handling
trap 'on_error $LINENO "$BASH_COMMAND"' ERR

on_error() {
    local lineno="$1"
    local cmd="$2"

    local RED=$(tput setaf 1)
    local YELLOW=$(tput setaf 3)
    local RESET=$(tput sgr0)

    echo
    echo "${RED}ERROR DETECTED${RESET}"
    echo "${YELLOW}Line: $lineno"
    echo "Command: '$cmd'"
    echo "Waiting 10 seconds before continuing...${RESET}"
    echo

    sleep 10
}

##################################################################################################################################

# Get current directory of the script
installed_dir="$(dirname "$(readlink -f "$0")")"

##################################################################################################################################

# Debug mode switch
export DEBUG=false

if [ "$DEBUG" = true ]; then
    echo
    echo "------------------------------------------------------------"
    echo "Running $(basename "$0")"
    echo "------------------------------------------------------------"
    echo
    read -n 1 -s -r -p "Debug mode is on. Press any key to continue..."
    echo
fi

##############################################################################################################

install_packages() {
    if [ "$#" -eq 0 ]; then
        echo "No packages provided to install."
        return 1
    fi

    for pkg in "$@"; do
        echo
        echo "Installing package: $pkg"
        sudo pacman -S --noconfirm --needed "$pkg"
    done
}

##################################################################################################################################

remove_if_installed() {
    for pattern in "$@"; do
        # Find all installed packages that match the pattern (exact + variants)
        matches=$(pacman -Qq | grep "^${pattern}$\|^${pattern}-")
        
        if [ -n "$matches" ]; then
            for pkg in $matches; do
                echo "Removing package: $pkg"
                sudo pacman -R --noconfirm "$pkg"
            done
        else
            echo "No packages matching '$pattern' are installed."
        fi
    done
}

##############################################################################################################

if [ ! -f /usr/bin/hwinfo ]; then
  sudo pacman -S --noconfirm --needed hwinfo
fi

if hwinfo | grep "CORSAIR K70" > /dev/null 2>&1 ; then

	echo
	tput setaf 2
	echo "########################################################################"
	echo "################### Corsair keyboard to be installed"
	echo "########################################################################"
	tput sgr0
	echo

	sudo pacman -S --noconfirm --needed ckb-next-git
	installed_dir=$(pwd)
	[ -d $HOME"/.config/ckb-next" ] || mkdir -p $HOME"/.config/ckb-next"

	cp -r $installed_dir/settings/ckb-next/ckb-next.conf ~/.config/ckb-next.conf
	cp -f $installed_dir/settings/ckb-next/ckb-next.autostart.desktop ~/.config/autostart/ckb-next.autostart.desktop
	
	sudo systemctl enable ckb-next-daemon
	sudo systemctl start ckb-next-daemon

	echo
	tput setaf 6
	echo "########################################################################"
	echo "################### Corsair keyboard installed"
	echo "########################################################################"
	tput sgr0
	echo

fi

echo
tput setaf 6
echo "##############################################################"
echo "###################  $(basename $0) done"
echo "##############################################################"
tput sgr0
echo