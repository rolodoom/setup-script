#!/bin/bash

# --- External Functions ---
source lib/notify_lib.sh 2>/dev/null || true
source lib/check_libfuse.sh 2>/dev/null || true

# --- Variables ---
INSTALL_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
APPNAME="stretchly"

# --- Functions ---

help() {
    cat << EOF
Usage: $0 [option] [version]

Options:
  -h            Show this help message
  -i VERSION    Install Stretchly version VERSION (required)
  -u            Uninstall Stretchly

Examples:
  $0 -i 1.18.0
  $0 -u
EOF
    exit 1
}

install() {
    VERSION="$1"
    if [ -z "$VERSION" ]; then
        printf "Error: you must specify the version. Example: %s -i 1.18.0\n" "$0" >&2
        help
    fi

    notify "Installing Stretchly ${VERSION}" "heading"

    check_libfuse || return 1

    # Remove previous versions if they exist
    EXISTING=$(ls "$INSTALL_DIR"/Stretchly-*.AppImage 2>/dev/null || true)
    if [ -n "$EXISTING" ]; then
        printf "A previous version of Stretchly was found. Removing...\n"
        uninstall
    fi

    URL="https://github.com/hovancik/stretchly/releases/download/v${VERSION}/Stretchly-${VERSION}.AppImage"
    FILENAME="Stretchly-${VERSION}.AppImage"
    
    mkdir -p "$INSTALL_DIR"
    
    printf "Downloading Stretchly %s...\n" "$VERSION"
    wget -O "$INSTALL_DIR/$FILENAME" "$URL" || { printf "Download error: %s\n" "$URL" >&2; exit 1; }

    chmod +x "$INSTALL_DIR/$FILENAME"

    # Create symlink named 'stretchly'
    ln -sf "$INSTALL_DIR/$FILENAME" "$INSTALL_DIR/$APPNAME"

    # Create desktop entry
    mkdir -p "$DESKTOP_DIR"
    DESKTOP_FILE="$DESKTOP_DIR/$APPNAME.desktop"

    cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Stretchly
Exec=$INSTALL_DIR/$APPNAME %U
Terminal=false
Type=Application
Icon=stretchly
StartupWMClass=Stretchly
Comment=The break time reminder app
Categories=Utility;
EOF

    printf "Stretchly %s successfully installed in %s\n" "$VERSION" "$INSTALL_DIR"
}

uninstall() {
    APPIMAGE=$(ls "$INSTALL_DIR"/Stretchly-*.AppImage 2>/dev/null || true)

    if [ -z "$APPIMAGE" ]; then
        printf "Stretchly is not installed in %s\n" "$INSTALL_DIR"
        exit 0
    fi

    rm -f "$INSTALL_DIR"/Stretchly-*.AppImage
    rm -f "$INSTALL_DIR/$APPNAME"
    rm -f "$DESKTOP_DIR/$APPNAME.desktop"

    printf "Stretchly successfully uninstalled.\n"
}

main() {
    if [ $# -eq 0 ]; then
        help
    fi

    case "$1" in
        -h)
            help
            ;;
        -i)
            install "$2"
            ;;
        -u)
            uninstall
            ;;
        *)
            printf "Unknown option: %s\n" "$1"
            help
            ;;
    esac
}

main "$@"
