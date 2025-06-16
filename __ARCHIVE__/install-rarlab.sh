echo "-> Installing rar from RARLAB..."

# 1. Descargar el software
wget -O rarlinux-x64.tar.gz https://www.rarlab.com/rar/rarlinux-x64-701.tar.gz

# 2. Extraer el tarball
tar xzf rarlinux-x64.tar.gz

# 3. Mover rar a un directorio adecuado
sudo mv rar /usr/local/rar

# 4. Crear un enlace simbólico para que `nvim` sea accesible globalmente
sudo ln -sf /usr/local/rar/rar /usr/local/bin/rar
sudo ln -sf /usr/local/rar/unrar /usr/local/bin/unrar 

# 5. Verificar la instalación
rar -iver

# 6. Limpiar archivos
rm -rf rarlinux-x64.tar.gz
