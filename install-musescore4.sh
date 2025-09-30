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
  notify "Installing MuseScore Studio ${MSS_VERSION}" "heading"

  check_libfuse || return 1
  
  if [[ -f "${MSS_FILENAME}" ]]; then
    echo "Found existing: ${MSS_FILENAME}"
  else
    wget "${MSS_URL}" || notify "Download failed" "error"
  fi
  
  chmod +x "${MSS_FILENAME}"
  "./${MSS_FILENAME}" install || notify "Installation failed" "error"

  notify "Installing MuseScore Studio ${MSS_VERSION} installed succesfully" "success"
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

    # Remove all MuseScore-related mime type icons (svg, png, any size)
    find "${icon_dir}" -type f -path "*/mimetypes/*" -name "*musescore4portable*" -delete
  fi

   # Remove MIME files related to MuseScore
  local mime_base="${HOME}/.local/share/mime"
  for dir in application x-scheme-handler packages; do
    if [ -d "${mime_base}/${dir}" ]; then
      find "${mime_base}/${dir}" -type f -iname "*musescore*" -delete
    fi
  done

  # Update MIME database
  update-mime-database "${mime_base}" >/dev/null 2>&1
  
  notify "MuseScore Studio ${MSS_VERSION} completely removed" "success"
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