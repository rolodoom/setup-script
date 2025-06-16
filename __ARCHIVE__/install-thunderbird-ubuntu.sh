echo "-> Installing thunderbird..."
sudo snap remove --purge thunderbird
sudo apt purge thunderbird

sudo add-apt-repository ppa:mozillateam/ppa

echo '
Package: thunderbird*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001

Package: thunderbird*
Pin: release o=Ubuntu
Pin-Priority: -1
' | sudo tee /etc/apt/preferences.d/mozillateamppa

sudo apt-get update && sudo apt-get install thunderbird -y
