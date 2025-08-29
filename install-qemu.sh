#!/bin/bash

# --- External Functions ---

# Load the notify function
source lib/notify_lib.sh

notify "Installing QEMU" "heading"
sudo apt install qemu-system libvirt-daemon-system virt-manager
sudo virsh net-autostart default

notify "Adding $USER to libvirt"
sudo usermod -aG libvirt $USER