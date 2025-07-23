#!/bin/bash

# --- External Functions ---

# Load the notify function
source lib/notify_lib.sh

notify "Installing liquorix kernel" "heading"
curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash
