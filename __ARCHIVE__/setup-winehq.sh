echo "-> Setting WineHQ..."
# --------------------------------
# ~/.wine
# --------------------------------
winecfg
winetricks corefonts

# --------------------------------
# ~/.winebottles
# --------------------------------
mkdir -p ~/.winebottles/
# make backup
cp -r ~/.wine ~/.winebottles/.wine-base

# Create bottles
cp -r ~/.winebottles/.wine-base ~/.winebottles/Finale27
cp -r ~/.winebottles/.wine-base ~/.winebottles/NeuralAmpModeler
cp -r ~/.winebottles/.wine-base ~/.winebottles/PhotoScore7
cp -r ~/.winebottles/.wine-base ~/.winebottles/ReCycle
cp -r ~/.winebottles/.wine-base ~/.winebottles/SpitfireAudio
cp -r ~/.winebottles/.wine-base ~/.winebottles/StevenSlateAudio
cp -r ~/.winebottles/.wine-base ~/.winebottles/Toontrack

# Set default values for prefixes
WINEPREFIX=~/.winebottles/SpitfireAudio winetricks dxvk


# --------------------------------
# Add to yabridgectl
# --------------------------------
# Default VST folders
mkdir -p ~/.wine/drive_c/Program\ Files/Common\ Files/VST2
mkdir -p ~/.wine/drive_c/Program\ Files/Common\ Files/VST3
mkdir -p ~/.winebottles/NeuralAmpModeler/drive_c/Program\ Files/Common\ Files/VST3
mkdir -p ~/.winebottles/SpitfireAudio/drive_c/Program\ Files/Common\ Files/VST3
mkdir -p ~/.winebottles/SpitfireAudio/drive_c/Program\ Files/VstPlugins
mkdir -p ~/.winebottles/StevenSlateAudio/drive_c/Program\ Files/Common\ Files/VST3
mkdir -p ~/.winebottles/Toontrack/drive_c/Program\ Files/VstPlugins

# Add them to yabridgcetl
yabridgectl add "$HOME/.wine/drive_c/Program Files/Common Files/VST2"
yabridgectl add "$HOME/.wine/drive_c/Program Files/Common Files/VST3"
yabridgectl add "$HOME/.winebottles/NeuralAmpModeler/drive_c/Program Files/Common Files/VST3"
yabridgectl add "$HOME/.winebottles/SpitfireAudio/drive_c/Program Files/Common Files/VST3"
yabridgectl add "$HOME/.winebottles/SpitfireAudio/drive_c/Program Files/VstPlugins"
yabridgectl add "$HOME/.winebottles/StevenSlateAudio/drive_c/Program Files/Common Files/VST3"
yabridgectl add "$HOME/.winebottles/Toontrack/drive_c/Program Files/VstPlugins"
