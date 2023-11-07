#!/bin/bash

while ! sudo apt install sway swaylock wl-clipboard python3-pip brightnessctl playerctl rofi grim slurp -y; do
    echo -e "\e[1;31minstallation of utilities failed!\e[m"
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
rofi-theme-selector
