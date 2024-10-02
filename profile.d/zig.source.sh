${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

zig() ( command ${FUNCNAME} "$@"; )
f.x zig


zig.doc.urls() ( echo ; ) # urls here
f.x zig.doc.urls

zig.doc() (
    set -Eeuo pipefail; shopt -s nullglob
    for _u in $(${FUNCNAME}.urls); do xdg-open ${_u}; done
)
f.x zig.doc

zig.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x zig.env

zig.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}{,.${_shell}}
}
f.x zig.session

zig.installer() (
    set -Eeuo pipefail # DO NOT shopt -s nullglob
    binstall.installer ${FUNCNAME%.*}
)
f.x zig.installer

sourced || true
