#!/bin/bash

while ! sudo sway sway-lock wl-clipboard python3-pip brightnessctl -y; do
    color "1;31" "installation of utilities failed!"
done

# necessary for autotiling python script
pip install i3ipc

# install autotiling pythong script
cd ~/.personal/repos/other || exit 1
git clone https://github.com/nwg-piotr/autotiling.git
chmod +x ./autotiling/autotiling/main.py

# necessary to change brightness (without sudo)
sudo chmod +s $(which brightnessctl)
