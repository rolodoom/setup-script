#!/bin/bash

# --- User Provided URLs ---
MSS_URL="https://github.com/musescore/MuseScore/releases/download/v4.6.0/MuseScore-Studio-4.6.0.252730944-x86_64.AppImage"
MSM_URL="https://muse-cdn.com/Muse_Sounds_Manager_x64.deb"

# --- Derived Variables ---
MSS_FILENAME="${MSS_URL##*/}"
MSM_FILENAME="${MSM_URL##*/}"

# Extract version from MSS_URL
MSS_VERSION=$(echo "$MSS_FILENAME" | grep -oP 'MuseScore-Studio-\K\d+\.\d+\.\d+')

# --- External Functions ---
source lib/notify_lib.sh
source lib/check_libfuse.sh

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
  check_libfuse || return 1

  local installed_file
  installed_file=$(ls -1 ~/.local/bin/MuseScore-Studio-*.AppImage 2>/dev/null | head -n1)

  if [[ -n "$installed_file" ]]; then
    local installed_version
    installed_version=$(basename "$installed_file" | grep -oP 'MuseScore-Studio-\K\d+\.\d+\.\d+')

    if [[ "$installed_version" == "$MSS_VERSION" ]]; then
      notify "MuseScore Studio ${MSS_VERSION} is already installed. Skipping." "success"
      return 0
    else
      notify "Different version (${installed_version}) detected. Replacing with ${MSS_VERSION}." "warning"
      uninstall_ms_studio
    fi
  fi

  notify "Installing MuseScore Studio ${MSS_VERSION}" "heading"

  if [[ -f "${MSS_FILENAME}" ]]; then
    echo "Found existing: ${MSS_FILENAME}"
  else
    wget "${MSS_URL}" || notify "Download failed" "error"
  fi
  
  chmod +x "${MSS_FILENAME}"
  "./${MSS_FILENAME}" install || notify "Installation failed" "error"

  notify "MuseScore Studio ${MSS_VERSION} installed successfully" "success"
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

  notify "Muse Sounds Manager installed succesfully" "success"
}

uninstall_ms_studio() {
  confirm_action "This will uninstall MuseScore Studio." || return
  
  notify "Uninstalling MuseScore Studio" "heading"
  
  # Remove any AppImage and symlinks
  rm -f ~/.local/bin/MuseScore-Studio-*.AppImage
  rm -f ~/.local/bin/{mscore4portable,musescore4portable}
  
  # Remove desktop file
  local desktop_file="${HOME}/.local/share/applications/org.musescore.MuseScore4portable.desktop"
  [ -f "${desktop_file}" ] && rm -f "${desktop_file}"

  # Remove icon files
  local icon_dir="${HOME}/.local/share/icons/hicolor"
  if [ -d "${icon_dir}" ]; then
    find "${icon_dir}" -type f -name "mscore4portable.png" -delete
    find "${icon_dir}" -type f -path "*/mimetypes/*" -name "*musescore4portable*" -delete
  fi

  # Remove MIME files related to MuseScore
  local mime_base="${HOME}/.local/share/mime"
  for dir in application x-scheme-handler packages; do
    if [ -d "${mime_base}/${dir}" ]; then
      find "${mime_base}/${dir}" -type f -iname "*musescore*" -delete
    fi
  done

  update-mime-database "${mime_base}" >/dev/null 2>&1
  
  notify "MuseScore Studio completely removed" "success"
}

uninstall_ms_sounds() {
  confirm_action "This will uninstall Muse Sounds Manager." || return
  
  notify "Uninstalling Muse Sounds"
  sudo apt purge -y muse-sounds-manager
  notify "Muse Sounds removed" "success"
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