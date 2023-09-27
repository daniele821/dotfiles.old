#!/bin/bash

# MODIFIABLE
SSH_KEYS="danix1234 daniele821"

# FUNCTION
function ask_if_execute() {
    echo -e "${1} [Y/n] \c"
    read -r line
    line="${line,,}"
    if [[ "${line:0:1}" == "y" ]]; then
        return 0
    else
        return 1
    fi
}

# add ssh keys for github
# shellcheck disable=SC2086 # cannot quote name variable, because command wouldn't work (idk why!)
if ask_if_execute "Do you want to add ssh keys?"; then
    for name in ${SSH_KEYS}; do
        ssh-keygen -t ed25519 -f ~/.ssh/id_${name}
    done
fi

# fix configuration file which causes bluetooth problems
ORIGINAL_FILE="/etc/NetworkManager/conf.d/default-wifi-powersave-on.conf"
TMP_BUFFER=$(mktemp)
echo "[connection]
wifi.powersave = 3" >"${TMP_BUFFER}"
if diff "${TMP_BUFFER}" "${ORIGINAL_FILE}" &>/dev/null && ask_if_execute "Do you want to disable wifi powersave mode?"; then
    sudo sed -i 's/3/2/' "${ORIGINAL_FILE}"
    cat "${ORIGINAL_FILE}"
fi
rm "${TMP_BUFFER}"
unset TMP_BUFFER

# install gnome dracula theme
if ask_if_execute "Do you want to install dracula theme on gnome-terminal [WARNING: CREATE AN EMPTY PROFILE BEFORE]?"; then
    DIR="$(mktemp -d)"
    git clone https://github.com/dracula/gnome-terminal "${DIR}"
    cd "${DIR}" || exit 1
    ./install.sh
fi

# install rust
if ! "$HOME/.cargo/bin/rustup" --version &>/dev/null && ask_if_execute "Do you want to install rustup [NECESSARY FOR 'lsd']?"; then
    curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
fi

# install starship
if ask_if_execute "Do you really want to install/upgrade starship?"; then
    curl -sS https://starship.rs/install.sh | sh
fi

# install lsd
if "$HOME/.cargo/bin/rustup" --version &>/dev/null && ! lsd --version &>/dev/null && ask_if_execute "Do you want to install lsd?"; then
    "$HOME/.cargo/bin/cargo" install lsd
fi
