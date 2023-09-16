#!/bin/bash

### ----------- WARNING: place this file in the root of the repository ------------- ###

# (1) VARIABLES
# N.B: do not modify variables, the only operation allowed is to add variables inside arrays!

# (1.1) script path infos
SCRIPT_PWD="$(realpath ${BASH_SOURCE[0]})";
SCRIPT_DIR="$(dirname ${SCRIPT_PWD})";
SCRIPT_NAME="$(basename ${SCRIPT_PWD})"

# (1.2) all used/needed/tracked directories
DIRS=(
"${SCRIPT_DIR}/backup"
"${SCRIPT_DIR}/config"          
"${SCRIPT_DIR}/userconfig"  
"${SCRIPT_DIR}/init"
)

# (1.3) all configurations files
CONFIG_FILES=(
"${DIRS[1]}/files_to_track.txt"
)

# (1.4) all user configurations files
USER_CONFIG_FILES=(
"${DIRS[2]}/user_branch.txt"
)

# (1.5) all initializations files to execute if specific option is parsed
INIT_FILES_TO_EXECUTE=(
"${DIRS[3]}/apt-packages.sh"
"${DIRS[3]}/git-repos.sh"
"${DIRS[3]}/optional-init.sh"
"${DIRS[3]}/colors.sh"
)

# (1.6) flags  
FORCE_YES="n"   # n / y 
SHOW_DIFF="n"   # n / y 
SAVE=""         #   / r / s

### -------------------------------------------------------------------------------- ###

# (2) UTILITY FUNCTIONS

# (2.1) color string. $1: color, $2: str
function color(){
    echo -e "\e[${1}m${2}\e[m\c"
}

# (2.2) print error type in a specific color. $1: err type
function error_type(){
    case "$1" in 
        1) color "1;31" "ERROR: " ;;
        2) color "1;33" "WARNING: ";;
    esac
}

# (2.3) check branch is the whitelisted one
function check_branch(){
    CURRENT_BRANCH="$(git -C "${SCRIPT_DIR}" rev-parse --abbrev-ref HEAD)"
    WHITELISTED_BRANCH="$(cat ${USER_CONFIG_FILES[0]} 2>/dev/null)"
    if [[ "${CURRENT_BRANCH}" != "${WHITELISTED_BRANCH}" ]]; then 
        error_type "1" && color "0" "current branch \"" && color "1;36" "${CURRENT_BRANCH}" && color "0" "\" is not whitelisted. Try again on the branch \"" && color "1;36" "${WHITELISTED_BRANCH}" && color "0" "\"!\n"
        exit 1;
    fi;
}

# (2.4) ask user to do action. $1: msg
function ask_user(){
    echo -e "${1} \c";
    color "1;33" "[Y/n]? "
    if [[ "${FORCE_YES}" != "y" ]]; 
        then read -r answer </dev/tty;
        else answer="y" && echo "y";
    fi;
    if [[ "${answer,,}" == "y" ]];
        then return 0;
        else return 1;
    fi;
}

# (2.5) check git user and email are inserted
function check_git_user(){
    # name
    if [[ -z "$(git -C "${SCRIPT_DIR}" config user.name)" ]]; then
        error_type "2" && color "0" "git user.name not configurated.\nInsert git name: "
        read -r name;
        if [[ -z "${name}" ]]; then
            error_type "1" && color "0" "name not valid!\n";
            return 1;
        fi;
        git -C "${SCRIPT_DIR}" config user.name "${name}"
    fi;

    # email
    if [[ -z "$(git -C "${SCRIPT_DIR}" config user.email)" ]]; then
        error_type "2" && color "0" "git user.email not configurated.\nInsert git email: "
        read -r email;
        if [[ -z "${email}" ]]; then
            error_type "1" && color "0" "email not valid!\n";
            return 1;
        fi;
        git -C "${SCRIPT_DIR}" config user.email "${email}"
    fi;
}

# (2.6) read lines from file
function read_files(){
    while read -r file || [[ -n "${file}" ]]; do
        if ! git -C "${SCRIPT_DIR}" check-ignore -q "${DIRS[0]}/${file}" ; then
            if [[ -f "${file}" ]] || [[ -f "${DIRS[0]}${file}" ]]; then
                echo "${file}";
            fi;
            if [[ -d "${file}" ]] ; then
                find "${file}" -type f;
            fi;
            if [[ -d "${DIRS[0]}${file}" ]]; then
                find "${DIRS[0]}${file}" -type f | while read -r tmp; do
                    echo "${tmp:${#DIRS[0]}}";
                done;
            fi;
        fi;
    done < "${CONFIG_FILES[0]}" | sort -u
}

# (2.7) copy file into a destination and create directories if necessary. $1: src, $:2 dst
function copy(){
    mkdir -p $(dirname ${2})
    cp "${1}" "${2}"
}

# (2.8) save files using all options parsed. $1: file actual full path 
function save_file(){
    FILE="${1}"
    BACKUP="${DIRS[0]}${1}"
    if ! [[ -f "${FILE}" ]] && [[ -f "${BACKUP}" ]];
        then color "1;36" "${FILE}\n"; 
        [[ "${SHOW_DIFF}" == "y" ]] && color "1;35" "original" && color "" " file is missing!\n\n"
        [[ "${SAVE}" == "s" ]] && ask_user "Do you want to \e[1;33mremove\e[m backup file" && rm "${BACKUP}";
        [[ "${SAVE}" == "r" ]] && ask_user "Do you want to \e[1;33mcreate\e[m original file" && copy "${BACKUP}" "${FILE}";
    elif [[ -f "${FILE}" ]] && ! [[ -f "${BACKUP}" ]];
        then color "1;36" "${FILE}\n"; 
        [[ "${SHOW_DIFF}" == "y" ]] && color "1;35" "backup" && color "" " file is missing!\n\n";
        [[ "${SAVE}" == "s" ]] && ask_user "Do you want to \e[1;33mcreate\e[m backup file" && copy "${FILE}" ${BACKUP};
    elif ! diff -q "${FILE}" "${BACKUP}" &>/dev/null;
        then color "1;36" "${FILE}\n"; 
        if [[ "${SHOW_DIFF}" == "y" ]]; then
            [[ "${SAVE}" == "r" ]] && diff --color "${FILE}" "${BACKUP}";
            [[ "${SAVE}" == "r" ]] || diff --color "${BACKUP}" "${FILE}";
            echo;
        fi;
        [[ "${SAVE}" == "s" ]] && ask_user "Do you want to \e[1;33mupdate\e[m backup file" && copy "${FILE}" ${BACKUP};
        [[ "${SAVE}" == "r" ]] && ask_user "Do you want to \e[1;33mupdate\e[m original file" && copy "${BACKUP}" "${FILE}";
    fi;
}

### -------------------------------------------------------------------------------- ###

# (3) OPTION FUNCTIONS

# (3.1) print help message
function help_msg(){
    echo "\
USAGE:
    ./${SCRIPT_NAME} [flag options] [action option]
        
FLAG OPTIONS:
    -d      show diffs
    -f      force yes everytime a conferm is asked
    -s      save files from filesystem into this repo [OVERWRITES: -r]
    -r      restore files from this repo into filesystem [OVERWRITES: -s]

ACTION OPTIONS:
    -c      commit all changes              [flags: -d, -f]
    -e      edit all config files           [flags: -f]
    -h      help                            
    -i      run initialization scripts      [flags: -f]
    "
}

# (3.2) edit all config files
function edit_config_files(){
    EDITOR="/usr/bin/vim"
    for file in "${CONFIG_FILES[@]}" "${USER_CONFIG_FILES[@]}"; do 
        ask_user "Do you want to edit \e[1;36m$(basename ${file})" && "${EDITOR}" "${file}";
    done
}

# (3.3) run all initialization scripts
function run_init_scripts(){
    for script in "${INIT_FILES_TO_EXECUTE[@]}"; do
        ask_user "Do you want to run \e[1;36m$(basename ${script})" && { "${script}" || { error_type 1 && echo "initialization failed" && exit 1; }; };
    done;
}

# (3.4) do git commit
function git_commit(){
    if [[ "$(git -C "${SCRIPT_DIR}" status -s | wc -l)" == "0" ]]; then
        error_type "2"; echo "There is nothing to commit!";
        exit 0;
    fi;
    git -C "${SCRIPT_DIR}" status -s
    [[ "${SHOW_DIFF}" == "y" ]] && git -C "${SCRIPT_DIR}" diff HEAD
    if ask_user "Do you want to do commit"; then
        echo -e "Write commit name: \c";
        read -r line;
        if [[ -z "$line" ]]; then
            error_type "1"; echo "commit name not valid!"; 
            exit 1;
        fi;
        git -C "${SCRIPT_DIR}" pull;
        git -C "${SCRIPT_DIR}" add -A && git -C "${SCRIPT_DIR}" commit -m "${line}";
        ask_user "Do you want to push" && git -C "${SCRIPT_DIR}" push -u origin $(cat ${USER_CONFIG_FILES[0]})
    fi;
}

### -------------------------------------------------------------------------------- ###

# (4) EXECUTION

# (4.1) check git user info are configured (otherwise commit will fail!)
while ! check_git_user; do sleep 0; done

# (4.2) create user config files
for file in "${USER_CONFIG_FILES[@]}"; do
    mkdir -p "$(dirname ${file})" && touch "${file}";
done;

# (4.3) check branch is the whitelisted one
check_branch

# (4.4) create all directories
for dir in "${DIRS[@]}"; do
    mkdir -p "${dir}";
done

# (4.5) create all config files
for file in "${CONFIG_FILES[@]}"; do
    touch "${file}";
done;

# (4.6) create all initializers script files and make them executable
for file in "${INIT_FILES_TO_EXECUTE[@]}"; do
    touch "${file}" && chmod +x ${file};
done;

# (4.7) getopt
while getopts ':cdefhirs' OPTION; do
    case "${OPTION}" in
    c)
        git_commit;
        exit 0;
        ;;
    d)
        SHOW_DIFF="y";
        ;;
    e)
        edit_config_files;
        exit 0;
        ;;
    f)
        FORCE_YES="y";
        ;;
    h) 
        help_msg;
        exit 0;
        ;;
    i)
        run_init_scripts;
        exit 0;
        ;;
    r)
        SAVE="r"
        ;;
    s)
        SAVE="s"
        ;;
    esac;
done;

# (4.8) save files and exit
read_files | while read -r file; do
    save_file "${file}";
done;
exit 0;
