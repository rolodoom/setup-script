#!/bin/bash

# --- External Functions ---

# Load the notify function
source lib/notify_lib.sh

notify "Installing Flatpak software from Flathub.org" "heading"
sudo flatpak install flathub studio.kx.carla com.github.tchx84.Flatseal com.sigil_ebook.Sigil com.spotify.Client io.github.giantpinkrobots.flatsweep org.audiveris.audiveris org.gnome.gitlab.dqpb.GMetronome org.libretro.RetroArch org.nickvision.tubeconverter org.torproject.torbrowser-launcher
