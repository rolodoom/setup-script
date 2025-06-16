#!/bin/bash

# --- External Functions ---

# Load the notify function
source lib/notify_lib.sh

notify "Installing liquorix kernel" "heading"
curl 'https://liquorix.net/add-liquorix-repo.sh' | sudo bash
