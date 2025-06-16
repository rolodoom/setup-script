#!/bin/bash


# --- External Functions ---

# Load the notify function
source lib/notify_lib.sh

# --- Functions ---

# Function to display help
show_help() {
  echo "Usage: $0 [OPTION]"
  echo "Manage installation/uninstallation:"
  echo "  -i    Run install script"
  echo "  -u    Run uninstall script"
  echo "  -h    Show this help"
  exit 0
}

# remove old soft
remove(){
    notify "removing..."
    rm -rf ~/.lv2/neural_amp_modeler.lv2
    rm -rf neural-amp-modeler-lv2
    rm -rf neural-amp-modeler-ui
}


# compile NAM
nam(){
    # ---------------------------
    notify "NAM - Neural Amp Modeler"
    # ---------------------------
    # sudo apt install cmake -y
    git clone --recurse-submodules -j4 https://github.com/mikeoliphant/neural-amp-modeler-lv2
    cd neural-amp-modeler-lv2/build
    cmake .. -DCMAKE_BUILD_TYPE="Release" -DUSE_NATIVE_ARCH=OFF
    make -j4
    mkdir -p ~/.lv2/
    cp -r neural_amp_modeler.lv2 ~/.lv2/
    cd ..
    cd ..
    rm -rf neural-amp-modeler-lv2
}

nam_gui(){
    notify "NAM gui"
    # sudo apt install libcairo2-dev libx11-dev lv2-dev -y
    git clone https://github.com/brummer10/neural-amp-modeler-ui.git
    cd neural-amp-modeler-ui
    git submodule init
    git submodule update
    make
    make install
    cd ..
    rm -rf neural-amp-modeler-ui
}


# Install dependencies
dependencies() {
    notify "Installing dependencies"
    sudo apt install -y cmake libcairo2-dev libx11-dev lv2-dev
}


# Install subroutine
install(){
    notify "Installing NAM" "heading"

    remove
    dependencies
    nam
    nam_gui

}

# Uninstall subroutine
uninstall(){

    # Safeguard confirmation
    read -p "⚠️  WARNING: This will uninstall the software. Continue? [y/N] " confirm
    confirm=${confirm,,}  # Convert to lowercase

    if [[ "$confirm" != "y" ]]; then
        echo "Uninstall cancelled."
        exit 0
    fi

    notify "Unstalling NAM" "heading"
    remove
}

# --- Main Logic ---
main() {
    while getopts ":iuh" opt; do
        case "$opt" in
            i) install ;;
            u) uninstall ;;
            h) show_help ;;
            *) echo "Invalid option: -$OPTARG"; show_help; exit 1 ;;
        esac
    done

    # If no options provided
    if [ $OPTIND -eq 1 ]; then
        show_help
    fi
}

# --- Entry Point ---
main "$@"
