#!/bin/bash

# --- External Functions ---

# Load the notify function
source lib/notify_lib.sh

notify "Installing asciiquarium" "heading"

curl -fsS https://dl.brave.com/install.sh | sh
