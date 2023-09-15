#!/bin/bash

function color(){
    echo -e "\e[${1}m${2}\e[m"
}

while ! sudo apt update -y; do
    color "1;31" "update failed"; 
done
while ! sudo apt upgrade -y; do 
    color "1;31" "upgrade failed"; 
done
while ! sudo apt install unclutter-xfixes vim ripgrep exa tree fzf zoxide bat code fonts-firacode gnome-tweaks gnome-shell-extension-manager deluge -y; do 
    color "1;31" "installation failed"
done
while ! sudo apt purge --auto-remove pop-shop -y; do 
    color "1;31" "purge of pop-shop failed"
done
while ! sudo apt update -y; do 
    color "1;31" "update failed"
done
while ! sudo apt upgrade -y; do 
    color "1;31" "upgrade failed"
done
while ! sudo apt autopurge -y; do 
    color "1;31" "autopurge failed"
done   