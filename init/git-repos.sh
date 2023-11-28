#!/bin/bash

# MODIFIABLE
CODE_EXTENSIONS=(
    "tamasfe.even-better-toml"
    "rust-lang.rust-analyzer"
    "mhutchie.git-graph"
    "foxundermoon.shell-format"
    "timonwong.shellcheck"
    "asvetliakov.vscode-neovim"
)

# create directory structure
mkdir -p ~/.personal/{repos/{mine,unibo,other},data}

# restore backup
"$(dirname "$(dirname "$(realpath "${BASH_SOURCE[0]}")")")/autosaver.sh" -by

# install vscode extension
for ext in "${CODE_EXTENSIONS[@]}"; do
    code --install-extension "${ext}"
done

# operations on backup
cd ~/.local/share/themes || exit 1
unzip Dracula.zip && mv gtk-master Dracula
unzip pop-dark-fixed.zip
cd ~/.local/share/fonts/Inconsolata || exit 1
unzip Inconsolata.zip && rm ./*.md ./*.txt

# clone repositories in other dir
cd ~/.personal/repos/other || exit 1
git clone https://github.com/cykerway/complete-alias
