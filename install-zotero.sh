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

    INSTALLER="Zotero-${VERSION}_linux-x86_64.tar.xz"
    notify "Downloading Zotero..."
    wget -O ${INSTALLER} "https://www.zotero.org/download/client/dl?channel=release&platform=linux-x86_64&version=${VERSION}"

    # Check dependencies
    if ! dpkg -l | grep -q "libdbus-glib-1-2" || ! dpkg -l | grep -q "libreoffice-java-common"; then
        notify "Installing missing dependencies..."
        sudo apt update
        sudo apt install -y libdbus-glib-1-2 libreoffice-java-common
    fi

    notify "Extracting Zotero..."
    sudo tar -xf ${INSTALLER} --transform='s/Zotero_linux-x86_64/zotero/' -C /opt
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
    echo "  -i VERSION   Install Zotero (X.X or X.X.X)"
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
                notify "Error: You must specify a version after -i. Example: $0 -i X.X[.X]" "error"
                exit 1
            fi
            # Validate version format X.X or X.X.X
            if [[ ! "$VERSION" =~ ^[0-9]+(\.[0-9]+){1,2}$ ]]; then
                notify "error" "Versión inválida: $VERSION"
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
