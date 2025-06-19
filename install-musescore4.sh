#!/bin/bash

# --- User Provided URLs ---
MSS_URL="https://github.com/musescore/MuseScore/releases/download/v4.5.2/MuseScore-Studio-4.5.2.251141401-x86_64.AppImage"
MSM_URL="https://muse-cdn.com/Muse_Sounds_Manager_x64.deb"

# --- Derived Variables ---
MSS_FILENAME="${MSS_URL##*/}"
MSM_FILENAME="${MSM_URL##*/}"

# Extract version from MSS_URL
MSS_VERSION=$(echo "$MSS_FILENAME" | grep -oP 'MuseScore-Studio-\K\d+\.\d+\.\d+')

# --- External Functions ---
source lib/notify_lib.sh

# --- Functions ---

show_help() {
  cat <<EOF
Usage: $0 [OPTIONS]

Install Options:
  -m    Install MuseScore Studio
  -s    Install Muse Sounds Manager
  -a    Install all components (both)

Uninstall Options:
  -M    Uninstall MuseScore Studio
  -S    Uninstall Muse Sounds Manager
  -A    Uninstall all components (both)
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

install_ms_studio() {
  notify "Installing MuseScore Studio ${MSS_VERSION}"
  
  if [[ -f "${MSS_FILENAME}" ]]; then
    echo "Found existing: ${MSS_FILENAME}"
  else
    wget "${MSS_URL}" || notify "Download failed" "error"
  fi
  
  chmod +x "${MSS_FILENAME}"
  "./${MSS_FILENAME}" install || notify "Installation failed" "error"
}

install_ms_sounds() {
  notify "Installing Muse Sounds Manager"
  
  if [[ -f "${MSM_FILENAME}" ]]; then
    echo "Found existing: ${MSM_FILENAME}"
  else
    wget -O "${MSM_FILENAME}" "${MSM_URL}" || notify "Download failed" "error"
  fi
  
  sudo apt install "./${MSM_FILENAME}" -y
  rm -f "${MSM_FILENAME}"
}

uninstall_ms_studio() {
  confirm_action "This will uninstall MuseScore Studio ${MSS_VERSION}." || return
  
  notify "Uninstalling MuseScore Studio" "heading"
  
  # Remove AppImage and symlinks
  local install_path="${HOME}/.local/bin/${MSS_FILENAME}"
  [ -f "${install_path}" ] && rm -f "${install_path}"
  rm -f ~/.local/bin/{mscore4portable,musescore4portable}
  
  # Remove desktop file
  local desktop_file="${HOME}/.local/share/applications/org.musescore.MuseScore4portable.desktop"
  [ -f "${desktop_file}" ] && rm -f "${desktop_file}"
  
  # Remove icon files
  local icon_dir="${HOME}/.local/share/icons/hicolor"
  if [ -d "${icon_dir}" ]; then
    # Remove mscore4portable.png in all resolution folders
    find "${icon_dir}" -type f -name "mscore4portable.png" -delete
    
    # Remove SVG mime type icons
    local mime_dir="${icon_dir}/scalable/mimetypes"
    [ -f "${mime_dir}/application-x-musescore4portable.svg" ] && rm -f "${mime_dir}/application-x-musescore4portable.svg"
    [ -f "${mime_dir}/application-x-musescore4portable+xml.svg" ] && rm -f "${mime_dir}/application-x-musescore4portable+xml.svg"
  fi
  
  echo "MuseScore Studio ${MSS_VERSION} completely removed"
}

uninstall_ms_sounds() {
  confirm_action "This will uninstall Muse Sounds Manager." || return
  
  notify "Uninstalling Muse Sounds" "heading"
  sudo apt purge -y muse-sounds-manager
}

# --- Main Logic ---
main() {
  # If no arguments provided
  [[ $# -eq 0 ]] && show_help

  while getopts ":msaMSAh" opt; do
    case "${opt}" in
      m) install_ms_studio ;;
      s) install_ms_sounds ;;
      a) install_ms_studio; install_ms_sounds ;;
      M) uninstall_ms_studio ;;
      S) uninstall_ms_sounds ;;
      A) uninstall_ms_studio; uninstall_ms_sounds ;;
      h) show_help ;;
      *) echo "Invalid option: -${OPTARG}"; show_help; exit 1 ;;
    esac
  done
}

# --- Entry Point ---
main "$@"