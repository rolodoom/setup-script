#!/bin/bash

# =============================================
# NEOVIM INSTALLER WITH ASTROVIM SUPPORT
# =============================================

# --- Constants ---
readonly NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
readonly NVIM_TAR_FILE="nvim-linux-x86_64.tar.gz"
readonly NVIM_DIR="nvim-linux-x86_64"
readonly NVIM_INSTALL_PATH="/usr/local/nvim" 
readonly ASTROVIM_REPO="https://github.com/AstroNvim/template"

# --- Configuration ---
readonly NVIM_BIN_PATH="/usr/local/bin/nvim"
readonly NVIM_CONFIG_DIR="$HOME/.config/nvim"
readonly NVIM_DATA_DIRS=(
    "$HOME/.local/share/nvim"
    "$HOME/.local/state/nvim" 
    "$HOME/.cache/nvim"
)

# --- External Functions ---
source lib/notify_lib.sh

# --- Functions ---

show_help() {
    cat <<EOF
USAGE:
  $0 [OPTION]

OPTIONS:
  -i    Install NeoVim (core only)
  -a    Install NeoVim + AstroVim configuration
  -u    Uninstall NeoVim completely
  -h    Show this help message
EOF
    exit 0
}

install_nvim() {
    notify "Starting NeoVim installation..." "heading"
    
    # Download release
    if ! wget "$NVIM_URL" -O "$NVIM_TAR_FILE"; then
        notify "Failed to download NeoVim" "error"
        return 1
    fi

    # Extract archive
    if ! tar xzf "$NVIM_TAR_FILE"; then
        notify "Failed to extract archive" "error"
        return 1
    fi

    # Remove previous install (if exists)
    sudo rm -rf "$NVIM_INSTALL_PATH"

    # Install to system
    if ! sudo mv "$NVIM_DIR" "$NVIM_INSTALL_PATH"; then
        notify "Installation failed" "error"
        return 1
    fi

    # Recreate symlink cleanly
    sudo rm -f "$NVIM_BIN_PATH"
    if ! sudo ln -s "$NVIM_INSTALL_PATH/bin/nvim" "$NVIM_BIN_PATH"; then
        notify "Could not create symlink" "error"
        return 1
    fi

    # Cleanup
    rm -f "$NVIM_TAR_FILE"

    # Verify
    if nvim --version &>/dev/null; then
        notify "NeoVim installed successfully!" "success"
        return 0
    else
        notify "NeoVim installation verification failed" "error"
        return 1
    fi
}

install_astrovim() {
    notify "Installing AstroVim configuration..."
    
    # Remove any existing config
    rm -rf "$NVIM_CONFIG_DIR"
    for dir in "${NVIM_DATA_DIRS[@]}"; do
        rm -rf "$dir"
    done

    # Clone template
    if git clone --depth 1 "$ASTROVIM_REPO" "$NVIM_CONFIG_DIR"; then
        rm -rf "$NVIM_CONFIG_DIR/.git"
        notify "AstroVim configured successfully!" "success"
        return 0
    else
        notify "Failed to clone AstroVim template" "error"
    fi
}

uninstall_nvim() {
    notify "Starting complete uninstall" "heading"
    
    # System files
    sudo rm -rf "$NVIM_INSTALL_PATH"
    sudo rm -f "$NVIM_BIN_PATH"

    # Config and data
    rm -rf "$NVIM_CONFIG_DIR"
    for dir in "${NVIM_DATA_DIRS[@]}"; do
        rm -rf "$dir"
    done

    notify "NeoVim completely removed from system" "success"
}

# --- Main Program ---
main() {
    [[ $# -eq 0 ]] && show_help

    while getopts ":iauh" opt; do
        case "$opt" in
            i) install_nvim ;;
            a) install_nvim && install_astrovim ;;
            u) uninstall_nvim ;;
            h) show_help ;;
            *) echo "Invalid option: -$OPTARG"; show_help; exit 1 ;;
        esac
    done
}

# --- Execution ---
main "$@"