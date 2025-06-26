#!/bin/bash
#set -e
##############################################################################################################
# Author    : Erik Dubois
# Website   : https://www.erikdubois.be
# Youtube   : https://youtube.com/erikdubois
##############################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##############################################################################################################

set -uo pipefail  # safer error handling (no unbound vars, no silent pipe fails)

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

# Get current directory of the script
installed_dir="$(dirname "$(readlink -f "$0")")"

# Debug mode switch
export DEBUG=true

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
    local packages=(
        discord
        dropbox
        insync
        signal-desktop
        signal-in-tray
        spotify
        telegram-desktop
    )

    for pkg in "${packages[@]}"; do
        echo
        echo "Installing package: $pkg"
        sudo pacman -S --noconfirm --needed "$pkg"
    done
}

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

echo
tput setaf 2
echo "################################################################################"
echo "Updating the system - sudo pacman -Syyu"
echo "################################################################################"
tput sgr0
echo

sudo pacman -Syyu --noconfirm

echo
tput setaf 2
echo "################################################################################"
echo "Removing selected packages"
echo "################################################################################"
tput sgr0
echo

remove_if_installed adobe-source-han-sans-cn-fonts
remove_if_installed adobe-source-han-sans-jp-fonts
remove_if_installed adobe-source-han-sans-kr-fonts

echo
tput setaf 2
echo "################################################################################"
echo "Installing selected packages"
echo "################################################################################"
tput sgr0
echo

install_packages

echo
tput setaf 2
echo "########################################################################"
echo "################### Build from AUR"
echo "########################################################################"
tput sgr0
echo

if ! pacman -Qi opera &>/dev/null; then
    yay -S opera --noconfirm
else
    echo "Opera is already installed."
fi


echo
tput setaf 3
echo "################################################################################"
echo "End of package installation"
echo "################################################################################"
tput sgr0
echo


echo
tput setaf 3
echo "########################################################################"
echo "################### Going to the Personal folder"
echo "########################################################################"
tput sgr0
echo

installed_dir=$(dirname $(readlink -f $(basename `pwd`)))
cd $installed_dir/Personal

sh 900-*
sh 910-*
sh 920-*
sh 930-*
sh 990-*
sh 999-*


tput setaf 3
echo "########################################################################"
echo "End current choices"
echo "########################################################################"
tput sgr0