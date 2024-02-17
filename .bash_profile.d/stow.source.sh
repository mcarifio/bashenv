running.bash && u.have $(basename ${BASH_SOURCE} .source.sh) || return 0
type -p stow.env &> /dev/null; declare -i _first_time=$?

stow.env() {
    : 'stow.env [${STOW_DIR}] # set up the stow environment in the current bash'
    export STOW_DIR="${1:-~/.local/stow}"
    [[ -d "${STOW_DIR}" ]] || mkdir -pv "${STOW_DIR}"
}; declare -fx stow.env

(( ${_first_time} )) && stow.env || >&2 echo "stow.env # run?"



