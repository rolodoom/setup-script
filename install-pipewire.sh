#!/bin/bash

# --- External Functions ---

# Load the notify function
source lib/notify_lib.sh

notify "Installing pipewire" "heading"

# ---------------------------
# Pipewire
# https://wiki.debian.org/PipeWire
# ---------------------------
sudo apt install pipewire-audio pipewire-jack libspa-0.2-jack -y

notify "Tell all apps that use JACK to now use the Pipewire JACK"
# Tell all apps that use JACK to now use the Pipewire JACK
sudo cp /usr/share/doc/pipewire/examples/ld.so.conf.d/pipewire-jack-*.conf /etc/ld.so.conf.d/
sudo ldconfig
notify "Configure latency on local user"
# Latency on local user
mkdir -p ~/.config/pipewire
cp /usr/share/pipewire/jack.conf ~/.config/pipewire
