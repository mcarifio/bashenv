${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

bashdb() ( command ${FUNCNAME} "$@"; )
f.x bashdb


bashdb.docs() (
    set -Eeuo pipefail; shopt -s nullglob
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} "$@" # hard-code urls here if desired
)
f.x bashdb.docs

bashdb.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x bashdb.env

bashdb.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell}
    source.if ${_completions}/${_cmd}
}
f.x bashdb.session

sourced
