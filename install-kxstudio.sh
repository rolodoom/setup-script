#!/bin/bash

# --- External Functions ---

# Load the notify function
source lib/notify_lib.sh

notify "Installing KXStudio" "heading"
# ---------------------------
# Add KXStudio Repository
# ---------------------------
notify "Installing dependencies"
# Install dependencies
sudo apt update && sudo apt install apt-transport-https gpgv wget -y
notify "Install the repositories"
# Install the Repo
wget https://launchpad.net/~kxstudio-debian/+archive/kxstudio/+files/kxstudio-repos_11.2.0_all.deb
sudo dpkg -i kxstudio-repos_*.deb
sudo apt update && sudo apt upgrade -y
rm -rf kxstudio-repos_*.deb
