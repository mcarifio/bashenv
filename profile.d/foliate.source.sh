${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

foliate() ( command ${FUNCNAME} "$@"; )
f.x foliate

foliate.doc.urls() ( echo ; ) # urls here
f.x foliate.doc.urls

foliate.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x foliate.doc

foliate.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x foliate.env

foliate.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x foliate.session

foliate.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    binstall.installer ${FUNCNAME%.*}
)
f.x foliate.installer

sourced || true
