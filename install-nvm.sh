#!/bin/bash

# --- External Functions ---

# Load the notify function
source lib/notify_lib.sh

DEFAULT_NVM_VERSION="0.40.1"

show_help() {
  cat <<EOF
NVM Manager
Usage:
  $0 -i [version]  # Install (default $DEFAULT_NVM_VERSION)
  $0 -u            # Complete uninstall
  $0 -h            # Show help
EOF
}

install() {
  version="${1:-$DEFAULT_NVM_VERSION}"
  notify "Installing NVM version $version..."
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v$version/install.sh" | bash

  notify "Installation complete. NVM $(nvm --version) installed." "success"

}

uninstall() {
  # Remove NVM directory
  rm -rf "${NVM_DIR:-$HOME/.nvm}"
  
  notify "NVM completely uninstalled" "success"
}

# --- Main Logic ---
case "$1" in
  -i) install "$2" ;;
  -u) uninstall ;;
  -h) show_help ;;
  *) show_help; exit 1 ;;
esac


