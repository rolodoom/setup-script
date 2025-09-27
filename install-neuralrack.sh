#!/bin/bash

# --- External Functions ---

# Load the notify function
source lib/notify_lib.sh

# --- Constants ---

BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/hicolor/scalable/apps"
LV2_DIR="$HOME/.lv2"
VST_DIR="$HOME/.vst"

BASE_URL="https://github.com/brummer10/NeuralRack/releases/download"
RAW_BASE="https://raw.githubusercontent.com/brummer10/NeuralRack/refs/heads/main/NeuralRack/standalone"

ICON_URL="$RAW_BASE/NeuralRack.svg"
DESKTOP_URL="$RAW_BASE/NeuralRack.desktop"

# --- Functions ---


remove(){
    notify "removing..."
    rm -f "$BIN_DIR/Neuralrack"
    rm -f "$VST_DIR/NeuralRackvst.so"
    rm -rf "$LV2_DIR/Neuralrack.lv2"
    rm -f "$ICON_DIR/NeuralRack.svg"
    rm -f "$DESKTOP_DIR/NeuralRack.desktop"
}


install() {
    ver="$1"

     # Validate that a version was provided
    if [[ -z "$ver" ]]; then
        help
        exit 1
    fi

    notify "Installing NeuralRack version $ver" "heading"

    # Remove previous installation
    remove

    # Create necessary directories
    mkdir -p "$BIN_DIR" "$VST_DIR" "$LV2_DIR" "$ICON_DIR" "$DESKTOP_DIR"

    # Create a single temporary work directory
    workdir=$(mktemp -d)

    notify "Download tarballs"
    curl -fL -o "$workdir/standalone.tar.xz" "$BASE_URL/v$ver/NeuralRack-app-v$ver-linux-x86_64.tar.xz"
    curl -fL -o "$workdir/vst2.tar.xz" "$BASE_URL/v$ver/NeuralRack-vst2-v$ver-linux-x86_64.tar.xz"
    curl -fL -o "$workdir/lv2.tar.xz" "$BASE_URL/v$ver/NeuralRack-v$ver-linux-x86_64.tar.xz"

    notify "Extract standalone"
    tar -xJ --strip-components=1 -f "$workdir/standalone.tar.xz" -C "$BIN_DIR"
    chmod +x "$BIN_DIR/Neuralrack"

    notify "Extract VST2 plugin"
    tar -xJ -f "$workdir/vst2.tar.xz" -C "$workdir"
    mv "$workdir"/*/*.so "$VST_DIR/"

    notify "Extract LV2 plugin"
    tar -xJ -f "$workdir/lv2.tar.xz" -C "$workdir"
    mv "$workdir"/*/Neuralrack.lv2 "$LV2_DIR/"

    notify "Download icon and desktop file"
    curl -fLo "$ICON_DIR/NeuralRack.svg" "$ICON_URL"
    curl -fLo "$DESKTOP_DIR/NeuralRack.desktop" "$DESKTOP_URL"

    # Clean up temporary work directory
    rm -rf "$workdir"
}



uninstall() {
    # Safeguard confirmation
    read -p "⚠️  WARNING: This will uninstall the software. Continue? [y/N] " confirm
    confirm=${confirm,,}  # Convert to lowercase

    if [[ "$confirm" != "y" ]]; then
        echo "Uninstall cancelled."
        exit 0
    fi

    notify "Uninstalling NeuralRack" "heading"
    remove
    
}


help() {
    echo "Usage:"
    echo "  $0 -i VERSION   Install NeuralRack VERSION"
    echo "  $0 -u           Uninstall NeuralRack"
    echo "  $0 -h           Show this help"
}

main() {
    case "$1" in
        -i) install "$2" ;;
        -u) uninstall ;;
        -h|"") help ;;
        *) help ;;
    esac
}

main "$@"
