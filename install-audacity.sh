#!/bin/bash

# --- External Functions ---
source lib/notify_lib.sh

# --- Variables ---
INSTALL_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
APPNAME="audacityportable"

# --- Functions ---

help() {
    cat << EOF
Usage: $0 [option] [version]

Options:
  -h            Show this help message
  -i VERSION    Install Audacity version VERSION
  -u            Uninstall Audacity

Examples:
  $0 -i 3.7.5
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

    URL="https://github.com/audacity/audacity/releases/download/Audacity-$VERSION/audacity-linux-$VERSION-x64-22.04.AppImage"
    FILENAME="audacity-linux-$VERSION-x64-22.04.AppImage"
    
    mkdir -p "$INSTALL_DIR"
    
    notify "Downloading Audacity $VERSION..."
    wget -O "$INSTALL_DIR/$FILENAME" "$URL" || { echo "Download failed"; exit 1; }

    chmod +x "$INSTALL_DIR/$FILENAME"

    # Create symlink
    ln -sf "$INSTALL_DIR/$FILENAME" "$INSTALL_DIR/$APPNAME"

    # Create desktop file
    mkdir -p "$DESKTOP_DIR"
    DESKTOP_FILE="$DESKTOP_DIR/$APPNAME.desktop"

    cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Audacity
GenericName=Sound Editor
GenericName[es]=Editor de audio
Comment=Record and edit audio files
Comment[es]=Grabar y editar archivos de audio
Icon=audacity
StartupWMClass=Audacity
Type=Application
Categories=AudioVideo;Audio;AudioVideoEditing;
Keywords=sound;music editing;voice channel;frequency;modulation;audio trim;clipping;noise reduction;multi track audio editor;edit;mixing;WAV;AIFF;FLAC;MP2;MP3;
Exec=$INSTALL_DIR/$FILENAME %F
StartupNotify=false
Terminal=false
MimeType=application/x-audacity-project;application/x-audacity-project+sqlite3;audio/basic;audio/x-aiff;audio/x-wav;audio/aac;audio/ac3;audio/mp4;audio/x-ms-wma;video/mpeg;audio/flac;audio/x-flac;audio/mpeg;application/ogg;audio/x-vorbis+ogg;
EOF

    notify "Audacity $VERSION installed successfully!" "success"
}

uninstall() {
    # Check if any AppImage exists
    APPIMAGE=$(ls "$INSTALL_DIR"/audacity-linux-*-x64-22.04.AppImage 2>/dev/null)

    if [ -z "$APPIMAGE" ]; then
        notify "Audacity is not installed in $INSTALL_DIR" "info"
        exit 1
    fi

    # Remove AppImage
    rm -f "$INSTALL_DIR"/audacity-linux-*-x64-22.04.AppImage
    # Remove symlink
    rm -f "$INSTALL_DIR/$APPNAME"
    # Remove desktop file
    rm -f "$DESKTOP_DIR/$APPNAME.desktop"
    # Remove Audacity URL handler desktop if exists
    if [ -f "$DESKTOP_DIR/audacity-url-handler.desktop" ]; then
        rm -f "$DESKTOP_DIR/audacity-url-handler.desktop"
    fi

    notify "Audacity uninstalled successfully." "success"
}



upgrade() {
    VERSION="$1"
    if [ -z "$VERSION" ]; then
        notify "You must specify a version to upgrade to." "error"
        help
    fi

    echo "Upgrading Audacity to version $VERSION..."

    # Check if AppImage exists
    APPIMAGE=$(ls "$INSTALL_DIR"/audacity-linux-*-x64-22.04.AppImage 2>/dev/null)
    if [ -z "$APPIMAGE" ]; then
        echo "No existing installation found. Installing version $VERSION..."
    else
        uninstall
    fi

    install "$VERSION"
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
