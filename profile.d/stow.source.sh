${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

stow.docs() (
    set -Eeuo pipefail; shopt -s nullglob
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} "$@" # hard-code urls here if desired
)
f.x stow.docs

stow.env() {
    : 'stow.env [${STOW_DIR}] # set up the stow environment in the current bash'
    export STOW_DIR="${1:-/${HOME}/.local/stow}"
    [[ -d "${STOW_DIR}" ]] || mkdir -pv "${STOW_DIR}"
}
f.x stow.env

stow.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x stow.session

stow.installer() ( ls -1 $(bashenv.profiled)/binstall.d/*${FUNCNAME%.*}*.*.binstall.sh; )
f.x stow.installer

sourced || true

