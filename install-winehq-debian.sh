#!/bin/bash

# --- External Functions ---
source lib/notify_lib.sh

# --- Configuration ---
DOWNGRADE_VERSION="9.0.0.0"
DOWNGRADE_VERSION_SHORT="9.0"
LATEST_VERSION_SHORT="10.0"
SCRIPT_NAME=$(basename "$0")

# --- Function Definitions ---

# Helper functions
get_installed_wine_version() {
    dpkg -l winehq-stable 2>/dev/null | grep '^ii' | awk '{print $3}' | cut -d'~' -f1
}

get_running_wine_version() {
    wine --version 2>/dev/null || echo "not-installed"
}

# Version check functions
is_downgrade_version_installed() {
    local running_ver=$(get_running_wine_version)
    [[ "$running_ver" == "wine-$DOWNGRADE_VERSION_SHORT" ]]
}

is_latest_version_installed() {
    local running_ver=$(get_running_wine_version)
    [[ "$running_ver" == "wine-$LATEST_VERSION_SHORT" ]]
}

is_known_version_installed() {
    is_downgrade_version_installed || is_latest_version_installed
}

# Installation functions
clean_install_wine() {
    # Always remove existing installation first
    remove_wine_packages
    remove_software
    
    # Then proceed with fresh installation
    add_repo
    
    case "$1" in
        --latest)
            install_latest_version
            ;;
        --downgrade)
            install_downgrade_version
            ;;
    esac
    
    install_software
    notify "Wine installation completed (Version: $(get_running_wine_version))" "success"
}

install_downgrade_version() {
    notify "Installing WineHQ stable $DOWNGRADE_VERSION" "heading"
    codename=$(shopt -s nullglob; awk '/^deb https:\/\/dl\.winehq\.org/ { print $3; exit 0 } END { exit 1 }' /etc/apt/sources.list /etc/apt/sources.list.d/*.list || awk '/^Suites:/ { print $2; exit }' /etc/apt/sources.list /etc/apt/sources.list.d/wine*.sources)
    suffix=$(dpkg --compare-versions "$DOWNGRADE_VERSION" ge 6.1 && ((dpkg --compare-versions "$DOWNGRADE_VERSION" eq 6.17 && echo "-2") || echo "-1"))
    sudo apt install --install-recommends -y {"winehq-stable","wine-stable","wine-stable-amd64","wine-stable-i386"}="$DOWNGRADE_VERSION~$codename$suffix"
    sudo apt-mark hold winehq-stable
}

install_latest_version() {
    notify "Installing latest WineHQ stable" "heading"
    sudo apt install --install-recommends winehq-stable -y
}

install_software() {
    notify "Installing additional software"
    sudo apt install -y winetricks cabextract
}

# Repository functions
add_repo() {
    if ! wine_repo_exists; then
        notify "Adding WineHQ repository"
        sudo dpkg --add-architecture i386
        sudo mkdir -pm755 /etc/apt/keyrings
        wget -O - https://dl.winehq.org/wine-builds/winehq.key | sudo gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key -
        sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/trixie/winehq-trixie.sources
        sudo apt update
    else
        notify "WineHQ repository already exists, skipping addition"
    fi
}

wine_repo_exists() {
    [ -f /etc/apt/sources.list.d/winehq-trixie.sources ] || \
    grep -q '^deb.*winehq\.org' /etc/apt/sources.list /etc/apt/sources.list.d/*.list 2>/dev/null
}

# Removal functions
remove_wine_packages() {
    notify "Removing Wine packages"
    sudo apt-mark unhold winehq-stable 2>/dev/null
    sudo apt purge -y winehq-stable wine-stable wine-stable-amd64 wine-stable-i386:i386 2>/dev/null
    sudo apt autoremove -y --purge 2>/dev/null
}

remove_software() {
    notify "Removing additional software"
    sudo apt purge -y winetricks cabextract 2>/dev/null
    sudo apt autoremove -y --purge 2>/dev/null
}

remove_repos() {
    notify "Removing WineHQ repositories"
    sudo rm -rf /etc/apt/sources.list.d/winehq-trixie.sources 2>/dev/null
    sudo rm -rf /etc/apt/keyrings/winehq-archive.key 2>/dev/null
}

# Uninstallation functions
uninstall_wine() {
    local current_ver=$(get_running_wine_version)
    if [[ "$current_ver" == "not-installed" ]]; then
        notify "Wine is not currently installed" "info"
        return
    fi

    read -p "⚠️  WARNING: This will uninstall Wine ($current_ver). Continue? [y/N] " confirm
    confirm=${confirm,,}

    if [[ "$confirm" != "y" ]]; then
        notify "Uninstall cancelled" "info"
        exit 0
    fi

    notify "Uninstalling Wine ($current_ver)" "heading"
    remove_wine_packages
    remove_software
    notify "Wine has been uninstalled (repos kept)" "success"
}

uninstall_wine_and_repos() {
    uninstall_wine
    remove_repos
    sudo apt update
    notify "Wine and repositories have been completely removed" "success"
}

# Help function
show_help() {
    echo "Usage:"
    echo "  Installation:"
    echo "    $SCRIPT_NAME -i --latest       Install latest WineHQ stable"
    echo "    $SCRIPT_NAME -i --downgrade    Install WineHQ stable $DOWNGRADE_VERSION"
    echo "  Uninstallation:"
    echo "    $SCRIPT_NAME -u               Uninstall WineHQ (keep repos)"
    echo "    $SCRIPT_NAME -r               Uninstall WineHQ and remove repos"
    echo "  Other:"
    echo "    $SCRIPT_NAME -h               Show this help"
    exit 0
}

# --- Main Logic ---
case "$1" in
    -i|--install)
        if [ -z "$2" ]; then
            notify "Error: Must specify --latest or --downgrade" "error"
            show_help
            exit 1
        fi
        
        running_ver=$(get_running_wine_version)
        
        # Handle unknown versions that need uninstallation
        if ! is_known_version_installed && [[ "$running_ver" != "not-installed" ]]; then
            notify "Unknown Wine version detected: $running_ver\nThis version needs to be uninstalled first" "warning"
            read -p "⚠️  Uninstall current version? [y/N] " confirm
            confirm=${confirm,,}
            if [[ "$confirm" != "y" ]]; then
                notify "Installation aborted by user" "error"
                exit 1
            fi
            remove_wine_packages
            remove_software
        fi
        
        # Determine target version
        case "$2" in
            --latest)
                if is_latest_version_installed; then
                    notify "Latest Wine version (wine-$LATEST_VERSION_SHORT) is already installed" "info"
                    exit 0
                fi
                target_version="latest version (wine-$LATEST_VERSION_SHORT)"
                action="Installing"
                ;;
            --downgrade)
                if is_downgrade_version_installed; then
                    notify "Wine $DOWNGRADE_VERSION (wine-$DOWNGRADE_VERSION_SHORT) is already installed" "info"
                    exit 0
                fi
                target_version="version $DOWNGRADE_VERSION (wine-$DOWNGRADE_VERSION_SHORT)"
                action="Downgrading to"
                ;;
            *)
                notify "Error: Must specify either --latest or --downgrade" "error"
                show_help
                exit 1
                ;;
        esac
        
        # Installation confirmation
        notify "Current Wine version: $running_ver\n$action $target_version" "heading"
        read -p "Proceed with installation? [y/N] " confirm
        confirm=${confirm,,}
        
        if [[ "$confirm" != "y" ]]; then
            notify "Installation cancelled by user" "info"
            exit 0
        fi
        
        clean_install_wine "$2"
        ;;
    -u)
        uninstall_wine
        ;;
    -r)
        uninstall_wine_and_repos
        ;;
    -h|--help)
        show_help
        ;;
    *)
        show_help
        exit 1
        ;;
esac
