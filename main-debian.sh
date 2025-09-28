#!/bin/bash

# --- External Functions ---

# Load the notify function
source lib/notify_lib.sh

notify "Main Debian Script" "heading"

notify "Configure contrib..."
sudo sed -i '/^deb /{/contrib/!s/$/ contrib/}' /etc/apt/sources.list
sudo apt update && sudo apt upgrade -y

notify "Installing requirements..."
sudo apt install -y wget curl htop btop git rsync zsh

./install-asciiquarium.sh
./install-brave.sh
./install-docker-debian.sh
#./install-firefox.sh
./install-flatpak.sh
# ./install-joplin.sh -i
# ./install-liquorix.sh
./install-neovim.sh -a
./install-pipewire.sh
./install-reaper.sh 7.46
./install-winehq-debian.sh -i --downgrade
./install-yabridge.sh
# ./install-zotero.sh -i 7.0.21

notify "Configure System for Audio Workstation"
notify "grub ..."
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/g' /etc/default/grub
sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sudo update-grub

notify "audio.conf..."
echo '# audio group
@audio           -       rtprio          90
@audio           -       memlock         unlimited' | sudo tee -a /etc/security/limits.d/audio.conf

notify "sysctl.d/99-custom.conf..."
echo 'vm.swappiness=10
fs.inotify.max_user_watches=600000' | sudo tee /etc/sysctl.d/99-custom.conf
sudo sysctl --system

notify "Installing Default Software..."
sudo apt install -y calibre dolphin-nextcloud dolphin-plugins gimp hunspell-es inkscape kcolorchooser kio-extras kbibtex keepassxc kwin-addons papirus-icon-theme polyphone tidy thunderbird
./cleanup-hunspell-es.sh

notify "Installing Default Audio Software..."
sudo apt install -y ardour ebumeter eq10q calf-plugins caps dpf-plugins dragonfly-reverb lsp-plugins soundconverter tap-plugins x42-plugins zam-plugins

./install-musescore4.sh -a
./install-audacity.sh -i 3.7.5

notify "Update user preferences..."
sudo usermod -aG docker $USER
sudo usermod -aG audio $USER

echo ""
notify "FINISHED! PLEASE REBOOT SYSTEM" "success"
echo ""

