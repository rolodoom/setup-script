#!/bin/bash

# --- External Functions ---

# Load the notify function
source lib/notify_lib.sh

INSTALL_DIR="/opt/zotero"
DESKTOP_LAUNCHER="$HOME/.local/share/applications/zotero.desktop"
DATA_DIR="$HOME/.zotero"


# --- Functions ---

install() {
    notify "Installing Zotero $VERSION" "heading"

    INSTALLER="Zotero-${VERSION}_linux-x86_64.tar.bz2"
    notify "Downloading Zotero..."
    wget -O ${INSTALLER} "https://www.zotero.org/download/client/dl?channel=release&platform=linux-x86_64&version=${VERSION}"

    # Check dependency
    if ! dpkg -l | grep -q "libdbus-glib-1-2"; then
        notify "libdbus-glib-1-2 not found, installing..."
        sudo apt update
        sudo apt install -y libdbus-glib-1-2
    fi

    notify "Extracting Zotero..."
    sudo tar -xjf ${INSTALLER} --transform='s/Zotero_linux-x86_64/zotero/' -C /opt
    sudo /opt/zotero/set_launcher_icon

    ln -sf ${INSTALL_DIR}/zotero.desktop ${DESKTOP_LAUNCHER}

    rm -f ${INSTALLER}

    notify "Zotero $VERSION installed!" "success"
}

uninstall() {
    if [ ! -d "$INSTALL_DIR" ]; then
        notify "Zotero is not installed in $INSTALL_DIR." "info"
        exit 1
    fi

    notify "Uninstalling Zotero..." "heading"
    sudo rm -rf ${INSTALL_DIR}
    rm -f ${DESKTOP_LAUNCHER}
    rm -rf ${DATA_DIR}
    notify "Zotero completely removed!" "success"
}


help() {
    echo "Usage: $0 [OPTION] [VERSION]"
    echo
    echo "Options:"
    echo "  -i VERSION   Install Zotero (version required, format X.X.XX, e.g., 7.0.21)"
    echo "  -u           Uninstall Zotero"
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
            VERSION="$2"
            if [ -z "$VERSION" ]; then
                notify "Error: You must specify a version after -i. Example: $0 -i 7.0.21" "error"
                exit 1
            fi
            # Validate version format X.X.XX (last number max 2 digits)
            if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]{1,2}$ ]]; then
                notify "Error: Version format invalid. Must be X.X.XX, e.g., 7.0.21" "error"
                exit 1
            fi
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
