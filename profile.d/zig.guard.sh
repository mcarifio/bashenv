# creation: guard.mkguard ${_name}
_guard=$(path.basename ${BASH_SOURCE})

zig() ( command ${FUNCNAME} "$@"; )
f.x zig


zig.docs() (
    set -Eeuo pipefail; shopt -s nullglob
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} "$@" # hard-code urls here if desired
)
f.x zig.docs

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
    source.if ${_completions}/${_cmd}.${_shell}
    source.if ${_completions}/${_cmd}
}
f.x zig.session

unset _guard
loaded "${BASH_SOURCE}"
