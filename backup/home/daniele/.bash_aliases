#!/bin/bash

# initializations
eval "$(zoxide init bash)"
eval "$(starship init bash)"
source ~/.personal/repos/other/complete-alias/complete_alias

# functions
function clear_zoxide(){
    zoxide query -ls | while read -r score path;
        do if [[ $score -le "$1" ]];
            then zoxide remove "${path}"
        fi;
    done;
}
function check_zoxide(){
    if cd "$@" &>/dev/null;
        then return 0;
    fi;
    if [[ "$(zoxide query -l "$@" | wc -l)" -le "1" ]];
        then z "$@"; 
        else zi "$@"; 
    fi;
}

# aliases
alias ls='exa --group-directories-first'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias cat='batcat'
alias sudo='sudo '
alias cd='check_zoxide'

# complete all aliases
complete -F _complete_alias "${!BASH_ALIASES[@]}"
