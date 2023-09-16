#!/bin/bash

# MODIFIABLE
SSH_KEYS="danix1234 daniele821"

# FUNCTION
function ask_if_execute(){
    echo -e "${1} [Y/n] \c"
    read -r line;
    line="${line,,}";
    if [[ "${line:0:1}" == "y" ]];
        then return 0;
        else return 1;
    fi;
}

# add ssh keys for github 
if ask_if_execute "Do you want to add ssh keys?";
    then for name in ${SSH_KEYS};
        do ssh-keygen -t ed25519 -f ~/.ssh/id_${name};
    done;
fi;

# install gnome dracula theme
if ask_if_execute "Do you want to install dracula theme on gnome-terminal [WARNING: CREATE AN EMPTY PROFILE BEFORE] ?";
    then DIR="$(mktemp -d)";
    git clone https://github.com/dracula/gnome-terminal "${DIR}";
    cd ${DIR} || exit 1;
    ./install.sh
fi;

# install starship
if ask_if_execute "Do you want to install starship ?";
    then curl -sS https://starship.rs/install.sh | sh
fi;