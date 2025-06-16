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


add_to_shell() {
  shell_config="$HOME/.zshrc"

  # Add NVM configuration if not already present
  if ! grep -q "NVM_DIR" "$shell_config"; then
    cat <<EOF >> "$shell_config"

# NVM Configuration
export NVM_DIR="\$HOME/.nvm"
[ -s "\$NVM_DIR/nvm.sh" ] && \. "\$NVM_DIR/nvm.sh"  # Load nvm
[ -s "\$NVM_DIR/bash_completion" ] && \. "\$NVM_DIR/bash_completion"  # Load nvm bash_completion
EOF
    notify "Added NVM configuration to $shell_config"
  fi
}


install() {
  version="${1:-$DEFAULT_NVM_VERSION}"
  notify "Installing NVM version $version..."
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v$version/install.sh" | bash

  # Add to shell configuration
  add_to_shell

  # Load NVM immediately
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"


  notify "Installation complete. NVM $(nvm --version) installed." "success"

}


uninstall() {
  # Remove NVM directory
  rm -rf "${NVM_DIR:-$HOME/.nvm}"
  
  # Remove all NVM-related content from shell configs
  for rc in ~/.bashrc ~/.zshrc ~/.bash_profile ~/.profile; do
    if [ -f "$rc" ]; then
      # Remove the complete NVM block including comment and empty lines around it
      sed -i '/^# NVM Configuration/,/^[^#]*bash_completion/d' "$rc"
      # Remove any remaining individual NVM lines (backward compatible)
      sed -i '\|NVM_DIR|d; \|nvm.sh|d; \|bash_completion|d' "$rc"
      # Clean up any resulting double empty lines
      sed -i '/^$/N;/^\n$/D' "$rc"
    fi
  done
  
  # Unset all NVM-related variables
  unset NVM_DIR NVM_CD_FLAGS NVM_BIN NVM_INC
  
  notify "NVM completely uninstalled" "success"
}

# --- Main Logic ---
case "$1" in
  -i) install "$2" ;;
  -u) uninstall ;;
  -h) show_help ;;
  *) show_help; exit 1 ;;
esac


