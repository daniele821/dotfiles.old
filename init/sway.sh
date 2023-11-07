#!/bin/bash

while ! sudo sway sway-lock wl-clipboard python3-pip brightnessctl playerctl rofi grim slurp -y; do
    color "1;31" "installation of utilities failed!"
done

# necessary to change brightness (without sudo)
sudo chmod +s "$(which brightnessctl)"

# necessary for autotiling python script
pip install i3ipc

# install autotiling pythong script
cd ~/.personal/repos/other || exit 1
git clone https://github.com/nwg-piotr/autotiling.git
chmod +x ./autotiling/autotiling/main.py

# install rofi themes
git clone https://github.com/lr-tech/rofi-themes-collection.git
mkdir -p ~/.local/share/rofi/themes/
cp rofi-themes-collection/themes/* ~/.local/share/rofi/themes/
rofi-theme-selector
