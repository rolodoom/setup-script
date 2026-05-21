#!/bin/bash

# --- External Functions ---

# Load the notify function
source lib/notify_lib.sh

INSTALLER_URL="https://github.com/robbert-vdh/yabridge/releases/download/5.1.1/yabridge-5.1.1.tar.gz"
BIN_PATH="/usr/bin"
LIB_PATH="/usr/lib"



install(){
    notify "Installing yabridgectl" "heading"

    # 1. Download the tarball
    wget -O yabridge.tar.gz $INSTALLER_URL

    # 2. Extract the tarball
    tar xzf yabridge.tar.gz

    # 3. Move yabridge to path
    sudo cp yabridge/yabridge* $BIN_PATH
    sudo cp yabridge/libyabridge* $LIB_PATH
    
    # 4. Verify installation
    yabridgectl --version

    # 5. Clean up
    rm -rf yabridge
    rm -rf yabridge.tar.gz
}

uninstall() {
    if ! compgen -G "$BIN_PATH/yabridge*" >/dev/null || \
    ! compgen -G "$LIB_PATH/libyabridge*" >/dev/null
    then
        notify "yabridge is not installed correctly." "info"
        exit 1
    fi

    notify "Uninstalling yabridgectl..." "heading"
    sudo rm -rf ${BIN_PATH}/yabridge*
    sudo rm -rf "${LIB_PATH}"/libyabridge*
    notify "yabridgectl completely removed!" "success"
}

help() {
    echo "Usage: $0 [OPTION]"
    echo
    echo "Options:"
    echo "  -i           Install"
    echo "  -u           Uninstall"
    echo "  -h           Show this help message"
}


# --- Main Subroutine ---

main() {
    # --- Parse arguments ---
    if [ $# -eq 0 ]; then
        help
        exit 1
    fi

    case "$1" in
        -i) ACTION="install" ;;
        -u) ACTION="uninstall" ;;
        -h) ACTION="help" ;;
        *) echo "Invalid option. Use -h for help." ; exit 1 ;;
    esac

    # --- Execute action ---
    case "$ACTION" in
        install) install ;;
        uninstall) uninstall ;;
        help) help ;;
    esac
}

# --- Call main with all script arguments ---
main "$@"
