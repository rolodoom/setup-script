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
source lib/notify_lib.sh 2>/dev/null || {
    echo "Warning: Notification library not found. Using basic messages."
    notify() { echo "==> $1"; }
}

# --- Functions ---

show_help() {
    cat <<EOF
NeoVim Manager (v0.2)

USAGE:
  $0 [OPTION]

OPTIONS:
  -i    Install NeoVim (core only)
  -a    Install NeoVim + AstroVim configuration
  -u    Uninstall NeoVim completely
  -h    Show this help message

EXAMPLES:
  $0 -i    # Install only NeoVim
  $0 -a    # Install with AstroVim
  $0 -u    # Complete uninstall
EOF
    exit 0
}

error_exit() {
    echo "Error: $1" >&2
    exit 1
}

install_nvim() {
    notify "Starting NeoVim installation..."
    
    # Download release
    if ! wget "$NVIM_URL" -O "$NVIM_TAR_FILE"; then
        error_exit "Failed to download NeoVim"
    fi

    # Extract archive
    if ! tar xzf "$NVIM_TAR_FILE"; then
        error_exit "Failed to extract archive"
    fi

    # Install to system
    sudo mv "$NVIM_DIR" "$NVIM_INSTALL_PATH" || error_exit "Installation failed"
    sudo ln -sf "$NVIM_INSTALL_PATH/bin/nvim" "$NVIM_BIN_PATH" || error_exit "Could not create symlink"

    # Cleanup
    rm -f "$NVIM_TAR_FILE"

    # Verify
    if nvim --version &>/dev/null; then
        notify "NeoVim installed successfully!"
        return 0
    else
        error_exit "NeoVim installation verification failed"
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
        notify "AstroVim configured successfully!"
        return 0
    else
        error_exit "Failed to clone AstroVim template"
    fi
}

uninstall_nvim() {
    notify "Starting complete uninstall..."
    
    # System files
    sudo rm -rf "$NVIM_INSTALL_PATH"
    sudo rm -f "$NVIM_BIN_PATH"

    # Config and data
    rm -rf "$NVIM_CONFIG_DIR"
    for dir in "${NVIM_DATA_DIRS[@]}"; do
        rm -rf "$dir"
    done

    notify "NeoVim completely removed from system"
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