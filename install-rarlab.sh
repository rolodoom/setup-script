#!/bin/bash

# --- Constants ---
readonly RAR_URL="https://www.rarlab.com/rar/rarlinux-x64-711.tar.gz"
readonly RAR_TAR_FILE="rarlinux-x64.tar.gz"
readonly RAR_DIR="rar"
readonly RAR_INSTALL_PATH="/usr/local/rar" 

# --- Configuration ---
readonly BIN_PATH="/usr/local/bin"
readonly RAR_BIN_PATH="/usr/local/bin/rar"
readonly UNRAR_BIN_PATH="/usr/local/bin/unrar"

# --- External Functions ---
source lib/notify_lib.sh

# --- Functions ---

show_help() {
    cat <<EOF
USAGE:
  $0 [OPTION]

OPTIONS:
  -i    Install
  -u    Uninstall
  -h    Show this help message
EOF
    exit 0
}

install() {
    notify "Starting rar installation..." "heading"
    
    # Download release
    if ! wget "$RAR_URL" -O "$RAR_TAR_FILE"; then
        notify "Failed to download rar" "error"
    fi

    # Extract archive
    if ! tar xzf "$RAR_TAR_FILE"; then
        notify "Failed to extract archive" "error"
    fi

    # Install to system
    sudo mv "$RAR_DIR" "$RAR_INSTALL_PATH" || notify "Installation failed" "error"
    sudo ln -sf "$RAR_INSTALL_PATH/rar" "$RAR_BIN_PATH" || notify "Could not create symlink" "error"
    sudo ln -sf "$RAR_INSTALL_PATH/unrar" "$UNRAR_BIN_PATH" || notify "Could not create symlink" "error"


    # Cleanup
    rm -f "$RAR_TAR_FILE"

    # Verify
    if rar -iver &>/dev/null; then
        notify "rar installed successfully!" "success"
        return 0
    else
        notify "rar installation verification failed" "error"
    fi
}

uninstall() {
    notify "Starting rar uninstall..." "heading"
    
    # System files
    sudo rm -rf "$RAR_INSTALL_PATH"

    # Config 
    sudo rm -f "$RAR_BIN_PATH"
    sudo rm -f "$UNRAR_BIN_PATH"

    # Cleanup
    rm -f "$RAR_TAR_FILE"
    rm -rf "$RAR_DIR"
    
    notify "rar completely removed from system" "success"
}

# --- Main Program ---
main() {
    [[ $# -eq 0 ]] && show_help

    while getopts ":iauh" opt; do
        case "$opt" in
            i) install ;;
            u) uninstall ;;
            h) show_help ;;
            *) echo "Invalid option: -$OPTARG"; show_help; exit 1 ;;
        esac
    done
}

# --- Execution ---
main "$@"