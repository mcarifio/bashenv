${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

# gleam() ( command ${FUNCNAME} "$@"; )
# f.x gleam


gleam.docs() (
    set -Eeuo pipefail; shopt -s nullglob
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} "$@" # hard-code urls here if desired
)
f.x gleam.docs

gleam.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x gleam.env

_gleam.session() {
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    source.if /usr/share/bash-completion/completions/${_cmd}{,.${_shell}}
}
f.x _gleam.session

gleam.session() {
    : '# called by .bashrc'
    _${FUNCNAME} ${1:-$(u.shell)} ${2:-${FUNCNAME%.*}}
}
f.x gleam.session

sourced || true

