#!/bin/bash

# --- External Functions ---

# Load the notify function
source lib/notify_lib.sh

INSTALL_DIR="/opt/Postman"
DESKTOP_LAUNCHER="$HOME/.local/share/applications/postman.desktop"
DATA_DIR="$HOME/Postman"

# --- Functions ---

install() {
    notify "Installing Postman" "heading"

    INSTALLER="postman-linux-x64.tar.gz"

    notify "Downloading Postman..."
    wget -O ${INSTALLER} https://dl.pstmn.io/download/latest/linux_64

    notify "Extracting Postman..."
    sudo tar -xzf ${INSTALLER} -C /opt
    rm -f ${INSTALLER}


    cat > "$DESKTOP_LAUNCHER" << EOF
[Desktop Entry]
Type=Application
Name=Postman
Icon=/opt/Postman/app/resources/app/assets/icon.png
Exec="/opt/Postman/Postman"
Comment=Postman Desktop App Categories=Development;Code;
EOF

    notify "Postman installed!" "success"
}

uninstall() {
    if [ ! -d "$INSTALL_DIR" ]; then
        notify "Postman is not installed in $INSTALL_DIR." "info"
        exit 1
    fi

    notify "Uninstalling Zotero..." "heading"
    sudo rm -rf ${INSTALL_DIR}
    rm -f ${DESKTOP_LAUNCHER}
    rm -rf ${DATA_DIR}
    notify "Postman completely removed!" "success"
}


help() {
    echo "Usage: $0 [OPTION]"
    echo
    echo "Options:"
    echo "  -i           Install Postman"
    echo "  -u           Uninstall Postman"
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
        -i)
            # VERSION="$2"
            # if [ -z "$VERSION" ]; then
            #     notify "Error: You must specify a version after -i. Example: $0 -i 7.0.21" "error"
            #     exit 1
            # fi
            # # Validate version format X.X.XX (last number max 2 digits)
            # if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]{1,2}$ ]]; then
            #     notify "Error: Version format invalid. Must be X.X.XX, e.g., 7.0.21" "error"
            #     exit 1
            # fi
            ACTION="install"
            ;;
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
