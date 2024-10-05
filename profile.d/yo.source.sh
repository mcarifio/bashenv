${1:-false} || u.haveP $(path.basename.part ${BASH_SOURCE} 0) || return 0

yo() ( command ${FUNCNAME} "$@"; )
f.x yo

yo.doc.urls() ( echo ; ) # urls here
f.x yo.doc.urls

yo.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x yo.doc

yo.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x yo.env

yo.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x yo.session

yo.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    binstall.installer ${FUNCNAME%.*}
)
f.x yo.installer

sourced || true
