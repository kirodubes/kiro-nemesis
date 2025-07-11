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
    local packages=(
        insync
        signal-desktop
        signal-in-tray
    )

    for pkg in "${packages[@]}"; do
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

remove_if_installed \
    adobe-source-han-sans-cn-fonts \
    adobe-source-han-sans-jp-fonts \
    adobe-source-han-sans-kr-fonts \
    xfsprogs \
    btrfs-progs \
    jfsutils \
    mkinitcpio-nfs-utils \
    xfburn

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
    if command -v yay >/dev/null 2>&1; then
        yay -S opera --noconfirm
    else
        echo "Yay is not installed. Skipping Opera installation."
    fi
else
    echo "Opera is already installed."
fi

echo
tput setaf 3
echo "################################################################################"
echo "End build from AUR"
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

cd "$installed_dir/Personal" || { echo "Cannot cd to $installed_dir/Personal"; exit 1; }

# chadwm autologin
# Run scripts if they exist and are executable
[[ -x fix-sddm-conf ]] && fix-sddm-conf

for script in 900-* 910-* 920-* 930-* 990-* 999-*; do
    [[ -x "$script" ]] && ./"$script"
done


tput setaf 3
echo "########################################################################"
echo "End current choices"
echo "########################################################################"
tput sgr0