#!/bin/bash

# --- External Functions ---

# Load the notify function
source lib/notify_lib.sh

notify "Installing yabridgectl" "heading"

# 1. Descargar el software
wget -O yabridge.tar.gz https://github.com/robbert-vdh/yabridge/releases/download/5.1.1/yabridge-5.1.1.tar.gz

# 2. Extraer el tarball
tar xzf yabridge.tar.gz

# 3. Mover software a las rutas adecaudas
sudo cp yabridge/yabridge* /usr/bin
sudo cp yabridge/libyabridge* /usr/lib

# 4. Verificar la instalación
yabridgectl --version

# 5. Limpiar archivos
rm -rf yabridge
rm -rf yabridge.tar.gz