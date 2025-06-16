echo "-> Install flatpak apps"
sudo flatpak install flathub com.spotify.Client com.usebottles.bottles io.github.giantpinkrobots.flatsweep io.gitlab.news_flash.NewsFlash org.kde.kdenlive org.nickvision.tubeconverter org.torproject.torbrowser-launcher
sudo flatpak update
flatpak override --user --filesystem=xdg-config/gtk-3.0:ro
