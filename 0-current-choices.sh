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
        insync
        dropbox
        spotify
    )

    for pkg in "${packages[@]}"; do
        echo
        echo "Installing package: $pkg"
        sudo pacman -S --noconfirm --needed "$pkg"
    done
}

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
echo "Installing selected packages"
echo "################################################################################"
tput sgr0
echo

install_packages

echo
tput setaf 3
echo "################################################################################"
echo "End of package installation"
echo "################################################################################"
tput sgr0
echo
