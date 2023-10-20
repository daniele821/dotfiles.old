#!/bin/bash

### ----------- WARNING: place this file in the root of the repository ------------- ###

# (1) VARIABLES
# N.B: do not modify variables, the only operation allowed is to add variables inside arrays!

# (1.1) script path infos
SCRIPT_PWD="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "${SCRIPT_PWD}")"
SCRIPT_NAME="$(basename "${SCRIPT_PWD}")"

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
    "${DIRS[2]}/file_editor.txt"
)

# (1.5) all initializations files to execute if specific option is parsed
INIT_FILES_TO_EXECUTE=(
    "${DIRS[3]}/apt-packages.sh"
    "${DIRS[3]}/git-repos.sh"
    "${DIRS[3]}/optional-init.sh"
    "${DIRS[3]}/colors.sh"
)

# (1.6) flags
ON_BRANCH="n" # n / y
FORCE_YES="n" # n / y
SHOW_DIFF="n" # n / y
ALLOW_DNG="n" # n / y
ACTION=""     #   / b / c / e / i / r / s

### -------------------------------------------------------------------------------- ###

# (2) UTILITY FUNCTIONS

# (2.1) color string. $1: color, $2: str
function color() {
    echo -e "\e[${1}m${2}\e[m\c"
}

# (2.2) print error type in a specific color. $1: err type
function error_type() {
    case "$1" in
    1) color "1;31" "ERROR: " ;;
    2) color "1;33" "WARNING: " ;;
    esac
}

# (2.3) check branch is the whitelisted one
function check_branch() {
    CURRENT_BRANCH="$(git -C "${SCRIPT_DIR}" rev-parse --abbrev-ref HEAD)"
    WHITELISTED_BRANCH="$(cat "${USER_CONFIG_FILES[0]}" 2>/dev/null)"
    if [[ "${CURRENT_BRANCH}" == "${WHITELISTED_BRANCH}" ]]; then
        ON_BRANCH="y"
    fi
}

# (2.4) kill script if branch is not the whitelisted one (MUST BE RUNNED AFTER check_branch)
function check_branch_and_kill() {
    if [[ "${ON_BRANCH}" != "y" ]]; then
        error_type "1" && color "0" "current branch \"" && color "1;36" "${CURRENT_BRANCH}" && color "0" "\" is not whitelisted. Try again on the branch \"" && color "1;36" "${WHITELISTED_BRANCH}" && color "0" "\"!\n" && exit 1
    fi
}

# (2.5) ask user to do action. $1: msg
function ask_user() {
    echo -e "${1} \c"
    color "1;33" "[Y/n]? "
    if [[ "${FORCE_YES}" != "y" ]]; then
        read -r answer </dev/tty
    else
        answer="y" && echo "y"
    fi
    if [[ "${answer,,}" == "y" ]]; then
        return 0
    else
        return 1
    fi
}

# (2.6) check git user and email are inserted
function check_git_user() {
    # name
    if [[ -z "$(git -C "${SCRIPT_DIR}" config user.name)" ]]; then
        error_type "2" && color "0" "git user.name not configurated.\nInsert git name: "
        read -r name
        if [[ -z "${name}" ]]; then
            error_type "1" && color "0" "name not valid!\n"
            return 1
        fi
        git -C "${SCRIPT_DIR}" config user.name "${name}"
    fi

    # email
    if [[ -z "$(git -C "${SCRIPT_DIR}" config user.email)" ]]; then
        error_type "2" && color "0" "git user.email not configurated.\nInsert git email: "
        read -r email
        if [[ -z "${email}" ]]; then
            error_type "1" && color "0" "email not valid!\n"
            return 1
        fi
        git -C "${SCRIPT_DIR}" config user.email "${email}"
    fi
}

# (2.7) read lines from file
function read_files() {
    while read -r file || [[ -n "${file}" ]]; do
        [[ -n "${file}" && "${file:0:1}" != "#" ]] && file="${HOME}/${file}"
        if ! git -C "${SCRIPT_DIR}" check-ignore -q "${DIRS[0]}/${file}"; then
            if [[ -f "${file}" ]] || [[ -f "${DIRS[0]}${file}" ]]; then
                echo "${file}"
            fi
            if [[ -d "${file}" ]]; then
                find "${file}" -type f
            fi
            if [[ -d "${DIRS[0]}${file}" ]]; then
                find "${DIRS[0]}${file}" -type f | while read -r tmp; do
                    echo "${tmp:${#DIRS[0]}}"
                done
            fi
        fi
    done <"${CONFIG_FILES[0]}" | sort -u
}

# (2.8) copy file into a destination and create directories if necessary. $1: src, $:2 dst
function copy() {
    mkdir -p "$(dirname "${2}")"
    cp "${1}" "${2}"
}

# (2.9) save file using all options parsed. $1: file actual full path
function save_file() {
    FILE="${1}"
    BACKUP="${DIRS[0]}${1}"
    if ! [[ -f "${FILE}" ]] && [[ -f "${BACKUP}" ]]; then
        color "1;36" "${FILE}\n"
        [[ "${SHOW_DIFF}" == "y" ]] && color "1;35" "original" && color "" " file is missing!\n\n"
        [[ "${ACTION}" == "s" ]] && ask_user "Do you want to \e[1;33mremove\e[m backup file" && rm "${BACKUP}"
        [[ "${ACTION}" == "b" ]] && ask_user "Do you want to \e[1;33mcreate\e[m original file" && copy "${BACKUP}" "${FILE}"
    elif [[ -f "${FILE}" ]] && ! [[ -f "${BACKUP}" ]]; then
        color "1;36" "${FILE}\n"
        [[ "${SHOW_DIFF}" == "y" ]] && color "1;35" "backup" && color "" " file is missing!\n\n"
        [[ "${ACTION}" == "s" ]] && ask_user "Do you want to \e[1;33mcreate\e[m backup file" && copy "${FILE}" "${BACKUP}"
        [[ "${ACTION}" == "b" && "${ALLOW_DNG}" == "y" ]] && ask_user "Do you want to \e[1;33mremove\e[m original file [DANGEROUS]" && rm "${FILE}" 
    elif ! diff -q "${FILE}" "${BACKUP}" &>/dev/null; then
        color "1;36" "${FILE}\n"
        if [[ "${SHOW_DIFF}" == "y" ]]; then
            [[ "${ACTION}" == "b" ]] && diff --color "${FILE}" "${BACKUP}"
            [[ "${ACTION}" == "b" ]] || diff --color "${BACKUP}" "${FILE}"
            echo
        fi
        [[ "${ACTION}" == "s" ]] && ask_user "Do you want to \e[1;33mupdate\e[m backup file" && copy "${FILE}" "${BACKUP}"
        [[ "${ACTION}" == "b" ]] && ask_user "Do you want to \e[1;33mupdate\e[m original file" && copy "${BACKUP}" "${FILE}"
    fi
}

# (2.10) save all files
function save_files() {
    read_files | while read -r file; do
        save_file "${file}"
    done
}

# (2.13) store action parsed from args. $1: action letter
function store_action() {
    if [[ -z "${ACTION}" ]]; then
        ACTION="${1}"
    else
        error_type 1 && echo "too many action flags!" && exit 1
    fi
}

### -------------------------------------------------------------------------------- ###

# (3) OPTION FUNCTIONS

# (3.1) print help message
function help_msg() {
    echo "\
USAGE:
    ./${SCRIPT_NAME} [options]
        
FLAG OPTIONS:
    -d      show diffs
    -f      force allow dangerous operations
    -y      try to automatically answer yes to all interactions

ACTION OPTIONS:
    -b      restore backup into filesystem      [flags: -d, -f, -y]
    -c      commit all changes                  [flags: -d, -y]
    -e      edit all config files               [flags: -y]
    -h      help                           
    -i      run initialization scripts          [flags: -y]
    -r      remove all directories              [flags: -y]
    -s      save files from filesystem          [flags: -d, -y]
    "
}

# (3.2) edit all config files
function edit_config_files() {
    if [[ -f "${USER_CONFIG_FILES[1]}" ]]; then
        EDITOR="$(cat "${USER_CONFIG_FILES[1]}")"
    fi
    if ! "${EDITOR}" --version &>/dev/null; then
        EDITOR="/usr/bin/vim"
    fi
    if ! "${EDITOR}" --version &>/dev/null; then
        EDITOR="/usr/bin/nano"
    fi
    for file in "${USER_CONFIG_FILES[@]}"; do
        ask_user "Do you want to edit \e[1;36m$(basename "${file}")" && mkdir -p "$(dirname "${file}")" && touch "${file}" && "${EDITOR}" "${file}"
    done
    if [[ "${ON_BRANCH}" == "y" ]]; then
        for file in "${CONFIG_FILES[@]}"; do
            ask_user "Do you want to edit \e[1;36m$(basename "${file}")" && mkdir -p "$(dirname "${file}")" && touch "${file}" && "${EDITOR}" "${file}"
        done
    fi
}

# (3.3) run all initialization scripts
function run_init_scripts() {
    for script in "${INIT_FILES_TO_EXECUTE[@]}"; do
        ask_user "Do you want to run \e[1;36m$(basename "${script}")" && { "${script}" || { error_type 1 && echo "initialization failed" && exit 1; }; }
    done
}

# (3.4) do git commit
function git_commit() {
    if [[ "$(git -C "${SCRIPT_DIR}" status -s | wc -l)" == "0" ]]; then
        error_type "2"
        echo "There is nothing to commit!"
        exit 0
    fi
    git -C "${SCRIPT_DIR}" status -s
    [[ "${SHOW_DIFF}" == "y" ]] && git -C "${SCRIPT_DIR}" diff HEAD
    if ask_user "Do you want to do commit"; then
        echo -e "Write commit name: \c"
        read -r line
        if [[ -z "$line" ]]; then
            error_type "1"
            echo "commit name not valid!"
            exit 1
        fi
        git -C "${SCRIPT_DIR}" pull
        git -C "${SCRIPT_DIR}" add -A && git -C "${SCRIPT_DIR}" commit -m "${line}"
        ask_user "Do you want to push" && git -C "${SCRIPT_DIR}" push -u origin "$(cat "${USER_CONFIG_FILES[0]}")"
    fi
}

# (3.5) remove all directories
function remove_dirs() {
    LEN="$((${#SCRIPT_DIR} + 1))"
    for dir in "${DIRS[@]}"; do
        if [[ -d "${dir}" ]]; then
            ask_user "Do you want to remove \e[1;36m${dir:${LEN}}\e[m" && rm -rf "${dir}"
        fi
    done
}

### -------------------------------------------------------------------------------- ###

# (4) EXECUTION

# (4.1) check branch is the whitelisted one
check_branch

# (4.2) initializations and checks
if [[ "${ON_BRANCH}" == "y" ]]; then

    for dir in "${DIRS[@]}"; do
        mkdir -p "${dir}"
    done
    for file in "${CONFIG_FILES[@]}" "${USER_CONFIG_FILES[@]}"; do
        touch "${file}"
    done
    for file in "${INIT_FILES_TO_EXECUTE[@]}"; do
        touch "${file}" && chmod +x "${file}"
    done
fi

# (4.3) getopt
while getopts ':bcdefhirsy' OPTION; do
    case "${OPTION}" in
    b)
        store_action "b"
        ;;
    c)
        store_action "c"
        ;;
    d)
        SHOW_DIFF="y"
        ;;
    e)
        store_action "e"
        ;;
    f)
        ALLOW_DNG="y"
        ;;
    h)
        help_msg
        exit 0
        ;;
    i)
        store_action "i"
        ;;
    r)
        store_action "r"
        ;;
    s)
        store_action "s"
        ;;
    y)
        FORCE_YES="y"
        ;;
    *)
        error_type 1 && echo -e "invalid option \e[1;36m-${OPTARG}\e[m" && exit 1
        ;;
    esac
done

# (4.4) execute based on action flag
case "${ACTION}" in
c)
    check_branch_and_kill
    while ! check_git_user; do sleep 0; done
    git_commit
    exit 0
    ;;
e)
    edit_config_files
    exit 0
    ;;
i)
    check_branch_and_kill
    run_init_scripts
    exit 0
    ;;
r)
    remove_dirs
    exit 0
    ;;
*)
    check_branch_and_kill
    save_files
    exit 0
    ;;
esac
