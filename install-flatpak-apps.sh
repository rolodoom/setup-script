#!/bin/bash

# --- External Functions ---

# Load the notify function
source lib/notify_lib.sh

notify "Installing Flatpak software from Flathub.org" "heading"
sudo flatpak install com.github.tchx84.Flatseal com.polyphone_soundfonts.polyphone com.sigil_ebook.Sigil com.spotify.Client io.github.giantpinkrobots.flatsweep io.gitlab.news_flash.NewsFlash org.audiveris.audiveris org.gnome.gitlab.dqpb.GMetronome org.kde.kcolorchooser org.libretro.RetroArch org.nickvision.tubeconverter org.torproject.torbrowser-launcher
