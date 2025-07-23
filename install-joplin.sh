#!/bin/bash

# --- External Functions ---

# Load the notify function
source lib/notify_lib.sh

# --- Functions ---

show_help() {
  cat <<EOF
Usage: $0 [OPTIONS]

Options:
  -i    Install Joplin
  -u    Uninstall Joplin
  -h    Show this help message
EOF
  exit 0
}


confirm_action() {
  local message="$1"
  read -rp "⚠️  ${message} Continue? [y/N] " confirm
  [[ "${confirm,,}" == "y" ]] || return 1
  return 0
}


install(){
    notify "Installing joplin" "heading"
    wget -O - https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash
    notify "Joplin successfully installed!" "success"
}

uninstall(){
    notify "uninstalling joplin" "heading"

    confirm_action "This will uninstall Joplin." || return
    
    # List of files and directories to remove
    local items_to_remove=(
        ~/JoplinBacku
        ~/.joplin
        ~/.config/joplin-desktop
        ~/.config/Joplin
        ~/.local/share/applications/appimagekit-joplin.desktop
    )
    
    # Remove each item silently (won't complain if missing)
    for item in "${items_to_remove[@]}"; do
        rm -rf "$item" 2>/dev/null
    done
    
    # Update desktop database
    update-desktop-database ~/.local/share/applications/ 2>/dev/null
    
    notify "Joplin successfully uninstalled!" "success"
}

# --- Main Logic ---
case "$1" in
  -i) install "$2" ;;
  -u) uninstall ;;
  -h) show_help ;;
  *) show_help; exit 1 ;;
esac
