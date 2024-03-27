stow.env() {
    : 'stow.env [${STOW_DIR}] # set up the stow environment in the current bash'
    export STOW_DIR="${1:-/${HOME}/.local/stow}"
    [[ -d "${STOW_DIR}" ]] || mkdir -pv "${STOW_DIR}"
}
f.complete stow.env

loaded "${BASH_SOURCE}"
