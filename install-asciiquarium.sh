#!/bin/bash

# --- External Functions ---

# Load the notify function
source lib/notify_lib.sh

notify "Installing asciiquarium" "heading"

# 1. Instalar las dependencias:
sudo apt install perl-modules libcurses-perl build-essential -y
sudo cpan -i Term::Animation

# 2. Clonar el repositorio
git clone --depth 1 https://github.com/nothub/asciiquarium.git

# 3. Copiar el ejecutable y dar permisos
chmod +x asciiquarium/asciiquarium
sudo cp asciiquarium/asciiquarium /usr/local/bin

#4. Limpiar
rm -rf asciiquarium
