#!/bin/bash

# MODIFIABLE
CODE_EXTENSIONS=(
    "Gruntfuggly.todo-tree"
    "mhutchie.git-graph"
    "timonwong.shellcheck"
)

# create directory structure
mkdir -p ~/.personal/{repos/{mine,unibo,other},data}

# init vscode
code && sleep 10 && killall code;
for extension in "${CODE_EXTENSIONS[@]}"; 
    do code --install-extension "${extension}";
done;

# restore backup
"$(dirname "$(dirname "$(realpath "${BASH_SOURCE[0]}")")")/autosaver.sh" -fb

# operations on backup
cd ~/.local/share/themes || exit 1
unzip Dracula.zip && mv gtk-master Dracula
unzip pop-dark-fixed.zip
touch ~/Templates/{text.txt,script.sh}
cd ~/.local/share/fonts/Inconsolata || exit 1
unzip Inconsolata.zip && rm ./*.md ./*.txt

# clone repositories in other dir
cd ~/.personal/repos/other || exit 1;
git clone https://github.com/cykerway/complete-alias
