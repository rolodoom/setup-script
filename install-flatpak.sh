#!/bin/bash

# --- External Functions ---
source lib/notify_lib.sh

# --- Constants ---
FLATHUB_APPS=(
    studio.kx.carla
    com.github.tchx84.Flatseal
    com.sigil_ebook.Sigil
    com.spotify.Client
    io.github.giantpinkrobots.flatsweep
    org.audiveris.audiveris
    org.gnome.gitlab.dqpb.GMetronome
    org.libretro.RetroArch
    org.nickvision.tubeconverter
    org.torproject.torbrowser-launcher
)

# --- Functions ---

install_flatpak() {
    notify "Installing Flatpak"
    sudo apt install flatpak -y
}

install_flatpak_plugin() {
    local de=$(echo "$XDG_CURRENT_DESKTOP" | tr '[:upper:]' '[:lower:]')
    notify "Detected desktop environment: $de"

    case "$de" in
        kde*)
            notify "Installing KDE Flatpak plugin"
            sudo apt install plasma-discover-backend-flatpak -y
            ;;
        gnome*)
            notify "Installing GNOME Flatpak plugin"
            sudo apt install gnome-software-plugin-flatpak -y
            ;;
        *)
            notify "Other desktop detected, skipping DE-specific plugin"
            ;;
    esac
}

add_flathub() {
    notify "Add the Flathub repository"
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
}

check_flatpak_ready() {
    if ! command -v flatpak &>/dev/null; then
        notify "Flatpak no está instalado. Operación abortada."
        return 1
    fi

    if ! flatpak remotes | grep -q '^flathub'; then
        notify "El repositorio Flathub no existe. Operación abortada."
        return 1
    fi

    return 0
}

install_flatpak_apps() {
    if ! check_flatpak_ready; then
        return 1
    fi

    notify "Installing Flatpak software from Flathub.org"
    sudo flatpak install -y flathub "${FLATHUB_APPS[@]}"
}

remove_flatpak_apps() {
    if ! check_flatpak_ready; then
        return 1
    fi

    notify "Removing Flatpak applications installed by this script"
    for app in "${FLATHUB_APPS[@]}"; do
        sudo flatpak uninstall -y "$app"
    done

    read -p "Do you want to remove unused Flatpak runtimes and dependencies? [y/N]: " response
    case "$response" in
        [Yy]* )
            notify "Removing unused Flatpak runtimes and dependencies"
            sudo flatpak uninstall --unused -y
            ;;
        * )
            notify "Skipped removing unused Flatpak runtimes"
            ;;
    esac
}


show_help() {
    echo "Usage: $0 [OPTION]"
    echo
    echo "Options:"
    echo "  -i    Install Flatpak, plugins, add Flathub, and install apps"
    echo "  -f    Install only Flatpak applications from Flathub"
    echo "  -u    Remove Flatpak applications installed by this script"
    echo "  -h    Show this help message"
    echo
}

main() {
    case "$1" in
        -i)
            notify "Enable Flatpak & Flathub.org" "heading"
            install_flatpak
            install_flatpak_plugin
            add_flathub
            install_flatpak_apps
            ;;
        -f)
            install_flatpak_apps
            ;;
        -u)
            remove_flatpak_apps
            ;;
        -h|"")
            show_help
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            ;;
    esac
}

# --- Execute ---
main "$1"
