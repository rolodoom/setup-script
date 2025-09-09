#!/bin/bash

# --- External Functions ---
source lib/notify_lib.sh

# --- Variables ---
INSTALL_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
APPNAME="marktext"

# --- Functions ---

help() {
    cat << EOF
Usage: $0 [option] [version]

Options:
  -h            Show this help message
  -i VERSION    Install MarkText version VERSION
  -u            Uninstall MarkText

Examples:
  $0 -i 0.17.1
  $0 -u
EOF
    exit 1
}

install() {
    VERSION="$1"
    if [ -z "$VERSION" ]; then
        notify "You must specify a version to install." "error"
        help
    fi

    # Si hay versiones previas, eliminarlas
    EXISTING=$(ls "$INSTALL_DIR"/marktext-*-x86_64.AppImage 2>/dev/null)
    if [ -n "$EXISTING" ]; then
        notify "Previous MarkText version found. Removing..."
        uninstall
    fi

    URL="https://github.com/marktext/marktext/releases/download/v$VERSION/marktext-x86_64.AppImage"
    FILENAME="marktext-$VERSION-x86_64.AppImage"
    
    mkdir -p "$INSTALL_DIR"
    
    notify "Downloading MarkText $VERSION..."
    wget -O "$INSTALL_DIR/$FILENAME" "$URL" || { echo "Download failed"; exit 1; }

    chmod +x "$INSTALL_DIR/$FILENAME"

    # Create symlink
    ln -sf "$INSTALL_DIR/$FILENAME" "$INSTALL_DIR/$APPNAME"

    # Create desktop file
    mkdir -p "$DESKTOP_DIR"
    DESKTOP_FILE="$DESKTOP_DIR/$APPNAME.desktop"

    cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=MarkText
Comment=Next generation markdown editor
Exec=$INSTALL_DIR/$FILENAME %F
Terminal=false
Type=Application
Icon=marktext
Categories=Office;TextEditor;Utility;
MimeType=text/markdown;
Keywords=marktext;
StartupWMClass=marktext
Actions=NewWindow;

[Desktop Action NewWindow]
Name=New Window
Exec=$INSTALL_DIR/$FILENAME --new-window %F
Icon=marktext
EOF

    notify "MarkText $VERSION installed successfully!" "success"
}


uninstall() {
    # Check if any AppImage exists
    APPIMAGE=$(ls "$INSTALL_DIR"/marktext-*-x86_64.AppImage 2>/dev/null)

    if [ -z "$APPIMAGE" ]; then
        notify "MarkText is not installed in $INSTALL_DIR" "info"
        exit 1
    fi

    # Remove AppImage
    rm -f "$INSTALL_DIR"/marktext-*-x86_64.AppImage
    # Remove symlink
    rm -f "$INSTALL_DIR/$APPNAME"
    # Remove desktop file
    rm -f "$DESKTOP_DIR/$APPNAME.desktop"

    notify "MarkText uninstalled successfully." "success"
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
        -a)
            upgrade "$2"
            ;;
        *)
            echo "Unknown option: $1"
            help
            ;;
    esac
}

main "$@"
