source.guard $(path.basename ${BASH_SOURCE}) || return 0

stow.env() {
    : 'stow.env [${STOW_DIR}] # set up the stow environment in the current bash'
    export STOW_DIR="${1:-~/.local/stow}"
    [[ -d "${STOW_DIR}" ]] || mkdir -pv "${STOW_DIR}"
}; declare -fx stow.env

eval "declare -ix _load_count_${_for}"
eval "${_for}.load_count() ( echo \$_load_count_${_for}; ); declare -fx ${_for}.load_count"
u.have ${_for}.env && (( _load_count_${_for} == 0 )) && ${_for}.env "$@"
(( ++_load_count_${_for} ))



