#!/bin/bash

# MODIFIABLE
CODE_EXTENSIONS=(
    "mhutchie.git-graph"
    "foxundermoon.shell-format"
    "timonwong.shellcheck"
    "redhat.java"
    "VisualStudioExptTeam.intellicode-api-usage-examples"
    "VisualStudioExptTeam.vscodeintellicode"
    "vscjava.vscode-gradle"
    "vscjava.vscode-java-debug"
    "vscjava.vscode-java-dependency"
    "vscjava.vscode-java-pack"
    "vscjava.vscode-java-test"
    "vscjava.vscode-maven"
    "asvetliakov.vscode-neovim"
)

# create directory structure
mkdir -p ~/.personal/{repos/{mine,unibo,other},data}

# restore backup
"$(dirname "$(dirname "$(realpath "${BASH_SOURCE[0]}")")")/autosaver.sh" -fb

# install vscode extension
for ext in "${CODE_EXTENSIONS[@]}"; do
    code --install-extension "${ext}"
done

# operations on backup
cd ~/.local/share/themes || exit 1
unzip Dracula.zip && mv gtk-master Dracula
unzip pop-dark-fixed.zip
touch ~/Templates/{text.txt,script.sh}
cd ~/.local/share/fonts/Inconsolata || exit 1
unzip Inconsolata.zip && rm ./*.md ./*.txt

# clone repositories in other dir
cd ~/.personal/repos/other || exit 1
git clone https://github.com/cykerway/complete-alias
