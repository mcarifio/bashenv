${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

# Wrap jq if needed.
# jq() ( command ${FUNCNAME} "$@"; )
# f.x jq


jq.docs() (
    set -Eeuo pipefail; shopt -s nullglob
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} "$@" # hard-code urls here if desired
)
f.x jq.docs

jq.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x jq.env

_jq.session() {
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    source.if /usr/share/bash-completion/completions/${_cmd}{,.${_shell}}
}
f.x _jq.session

jq.session() {
    : '# called by .bashrc'
    _${FUNCNAME} ${1:-$(u.shell)} ${2:-${FUNCNAME%.*}}
}
f.x jq.session

sourced
