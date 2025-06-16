#!/bin/bash

#install subroutine
install_winehq(){
    echo "-> Installing WineHQ..."
    sudo dpkg --add-architecture i386
    sudo mkdir -pm755 /etc/apt/keyrings
    wget -O - https://dl.winehq.org/wine-builds/winehq.key | sudo gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key -
    sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources
    sudo apt update
    sudo apt install --install-recommends winehq-stable winetricks cabextract -y
    echo "Done!!!"
}

#uninstall subroutine
uninstall_winehq(){
    echo "-> Uninstalling WineHQ..."
    sudo rm -rf /etc/apt/keyrings/winehq-archive.key
    sudo rm -rf /etc/apt/sources.list.d/winehq-noble.sources
    sudo apt purge winehq-stable
    sudo apt autoremove --purge
    echo "Done!!!"
}


usage() {
cat << EOF
Usage: $0 [OPTION]...

OPTIONS:
-i, --install           Install

-r, --remove,
-u, --uninstall         Uninstall/Remove

-h, --help              Show help
EOF
}


while [[ "$#" -gt 0 ]]; do
    case "${1:-}" in
        -i|--install)
        install_winehq

        exit 0
        ;;

        -r|--remove|-u|--uninstall)
        uninstall_winehq
        exit 0
        ;;

        -h|--help)
        usage
        exit 0
        ;;

        *)
        usage
        exit 1
        ;;
    esac
done

# If no options are provided, display help by default
usage
