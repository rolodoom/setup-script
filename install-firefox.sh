#!/bin/bash

set -e

source lib/notify_lib.sh

REPO_FILE="/etc/apt/sources.list.d/mozilla.list"
KEY_FILE="/etc/apt/keyrings/packages.mozilla.org.asc"
PREFERENCES_FILE="/etc/apt/preferences.d/mozilla"

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTION]

Manage Firefox installation on Debian using the official Mozilla repository.

Options:
  -i, --install       Install the latest Firefox from Mozilla
  -u, --uninstall     Uninstall Firefox and remove the Mozilla repository
      --add-repo      Add the Mozilla repository
      --remove-repo   Remove the Mozilla repository
  -h, --help          Show this help message

EOF
}

add_mozilla_repository() {
    notify "Adding Mozilla repository" "heading"

    sudo install -d -m 0755 /etc/apt/keyrings

    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg \
        -O- | sudo tee "$KEY_FILE" > /dev/null

    echo "deb [signed-by=$KEY_FILE] https://packages.mozilla.org/apt mozilla main" \
        | sudo tee "$REPO_FILE" > /dev/null

    cat <<EOF | sudo tee "$PREFERENCES_FILE" > /dev/null
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
EOF
}

remove_mozilla_repository() {
    notify "Removing Mozilla repository" "heading"

    sudo rm -f "$REPO_FILE"
    sudo rm -f "$KEY_FILE"
    sudo rm -f "$PREFERENCES_FILE"
}

install_firefox() {
    notify "Installing Firefox" "heading"

    # Remove Debian's ESR version before installing Mozilla Firefox.
    sudo apt purge firefox-esr -y

    add_mozilla_repository

    sudo apt-get update
    sudo apt-get install firefox -y
}

uninstall_firefox() {
    notify "Uninstalling Firefox" "heading"

    sudo apt purge firefox firefox-esr -y

    remove_mozilla_repository

    sudo apt-get update
}

main() {
    case "${1:---help}" in
        -i|--install)
            install_firefox
            ;;
        -u|--uninstall)
            uninstall_firefox
            ;;
        --add-repo)
            add_mozilla_repository
            ;;
        --remove-repo)
            remove_mozilla_repository
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo "Error: Unknown option '$1'" >&2
            echo "Use --help to see available options." >&2
            exit 1
            ;;
    esac
}

main "$@"
