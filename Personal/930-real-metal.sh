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

echo
tput setaf 3
echo "########################################################################"
echo "################### Removal of virtual machine software"
echo "########################################################################"
tput sgr0
echo

# Detect virtualization environment
# Detect shell and assign result accordingly
if [ -n "$BASH_VERSION" ]; then
    vm_type=$(systemd-detect-virt)
elif [ -n "$FISH_VERSION" ]; then
    set vm_type (systemd-detect-virt)
else
    echo "Unsupported shell"
    exit 1
fi

vm_type=$(systemd-detect-virt)
echo "Detected environment: $vm_type"

# Only proceed if NOT running inside a virtual machine
if [[ "$vm_type" == "none" ]]; then
    echo "Running on real hardware. Proceeding with cleanup..."

    # Disable and stop qemu-guest-agent.service if present
    if systemctl list-units --full -all | grep -q 'qemu-guest-agent.service'; then
        echo "Disabling qemu-guest-agent.service..."
        sudo systemctl stop qemu-guest-agent.service
        sudo systemctl disable qemu-guest-agent.service
    fi

    # Disable and stop vboxservice.service if present
    if systemctl list-units --full -all | grep -q 'vboxservice.service'; then
        echo "Disabling vboxservice.service..."
        sudo systemctl stop vboxservice.service
        sudo systemctl disable vboxservice.service
    fi

    # Remove QEMU packages if installed
    qemu_pkgs=$(pacman -Qsq '^qemu' 2>/dev/null)
    if [[ -n "$qemu_pkgs" ]]; then
        echo "Removing QEMU packages: $qemu_pkgs"
        sudo pacman -Rns --noconfirm $qemu_pkgs
    else
        echo "No QEMU packages found."
    fi

    # Remove VirtualBox packages if installed
    vbox_pkgs=$(pacman -Qsq '^virtualbox' 2>/dev/null)
    if [[ -n "$vbox_pkgs" ]]; then
        echo "Removing VirtualBox packages: $vbox_pkgs"
        sudo pacman -Rns --noconfirm $vbox_pkgs
    else
        echo "No VirtualBox packages found."
    fi

    echo "Cleanup complete."
else
    echo "Virtual machine detected ($vm_type). No action taken."
fi

echo
tput setaf 6
echo "##############################################################"
echo "###################  $(basename $0) done"
echo "##############################################################"
tput sgr0
echo