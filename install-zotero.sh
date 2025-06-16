#!/bin/bash

# --- External Functions ---

# Load the notify function
source lib/notify_lib.sh

notify "Installing Zotero" "heading"

VERSION=7.0.11

INSTALLER="Zotero-${VERSION}_linux-x86_64.tar.bz2"
notify "Downloading Zotero"
wget -O ${INSTALLER} https://www.zotero.org/download/client/dl\?channel\=release\&platform\=linux-x86_64\&version\=${VERSION}

# Check if libdbus-glib-1-2 is installed
if ! dpkg -l | grep -q "libdbus-glib-1-2"; then
  notify "libdbus-glib-1-2 is not installed. Installing ..."
  sudo apt update
  sudo apt install -y libdbus-glib-1-2
fi

notify "Extracting Zotero"
sudo tar -xjf Zotero-${VERSION}_linux-x86_64.tar.bz2 --transform='s/Zotero_linux-x86_64/zotero/' -C /opt
sudo /opt/zotero/set_launcher_icon
ln -sf /opt/zotero/zotero.desktop ~/.local/share/applications/zotero.desktop

rm -rf ${INSTALLER}
notify "Zotero installed!"

