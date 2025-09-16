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

check_pacman_lock() {
    local MAX_WAIT=30        # Total maximum wait time in seconds
    local WAIT_INTERVAL=5    # Time to wait between checks
    local elapsed=0

    while [ -e "/var/lib/pacman/db.lck" ]; do
        echo "Pacman is locked. Waiting $WAIT_INTERVAL seconds..."
        sleep "$WAIT_INTERVAL"
        elapsed=$((elapsed + WAIT_INTERVAL))

        if [ "$elapsed" -ge "$MAX_WAIT" ]; then
            echo "Warning: Removing /var/lib/pacman/db.lck after $MAX_WAIT seconds!"
            sudo rm -f /var/lib/pacman/db.lck
            break
        fi
    done
}

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
        check_pacman_lock
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
                check_pacman_lock
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

check_pacman_lock
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
    btrfs-progs \
    jfsutils \
    mkinitcpio-nfs-utils \
    vim \
    vlc-plugins-all \
    xfburn \
    xfsprogs

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

if ! pacman -Qi opera-ffmpeg-codecs-bin &>/dev/null; then
    if command -v yay >/dev/null 2>&1; then
        yay -S opera-ffmpeg-codecs-bin --noconfirm
    else
        echo "Yay is not installed. Skipping opera-ffmpeg-codecs-bin installation."
    fi
else
    echo "opera-ffmpeg-codecs-bin is already installed."
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
echo
echo "Getting default sddm configuration - autologin for user in chadwm"
echo "Changing /etc/sddm.conf.d/kde_settings.conf"
echo

# URL of the file to download
URL="https://raw.githubusercontent.com/erikdubois/arcolinux-nemesis/refs/heads/master/Personal/settings/sddm/kde_settings.conf"

# Target directory and filename
TARGET_DIR="/etc/sddm.conf.d"
TARGET_FILE="$TARGET_DIR/kde_settings.conf"

# Create the directory if it doesn't exist
sudo mkdir -p "$TARGET_DIR"

# Download the file to a temporary location
TMP_FILE=$(mktemp)
curl -fsSL "$URL" -o "$TMP_FILE"

# Check if download succeeded
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to download file from $URL"
  exit 1
fi

# Replace or insert the User field
if grep -q "^User=" "$TMP_FILE"; then
  sed -i "s/^User=.*/User=$USER/" "$TMP_FILE"
else
  echo -e "\nUser=$USER" >> "$TMP_FILE"
fi

# Move the modified file to the target location
sudo mv "$TMP_FILE" "$TARGET_FILE"

echo "SDDM configuration installed and set User=$USER at $TARGET_FILE"


echo
tput setaf 3
echo "Check if sddm configuration is correct"
tput sgr0
echo
CONF_FILE="/etc/sddm.conf.d/kde_settings.conf"

if [[ -f "$CONF_FILE" ]]; then
    if grep -q "User=$USER" "$CONF_FILE" && grep -q "Session=chadwm" "$CONF_FILE"; then
        echo "✅ Autologin is correctly configured for user '$USER' with session 'chadwm'."
    else
        echo "❌ Autologin is missing or incorrect in $CONF_FILE:"
        grep -E "User=|Session=" "$CONF_FILE"
    fi
else
    echo "❌ File $CONF_FILE does not exist."
fi

echo

for script in 900-* 910-* 920-* 930-* 990-* 999-*; do
    [[ -x "$script" ]] && ./"$script"
done


tput setaf 3
echo "########################################################################"
echo "End current choices"
echo "########################################################################"
tput sgr0