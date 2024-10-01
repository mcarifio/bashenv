# creation: guard.mkguard ${_name}
_guard=$(path.basename ${BASH_SOURCE})

# Wrap fd if needed.
# fd() ( command ${FUNCNAME} "$@"; )
# f.x fd


fd.docs() (
    set -Eeuo pipefail; shopt -s nullglob
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} "$@" # hard-code urls here if desired
)
f.x fd.docs

fd.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x fd.env

fd.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    source.if /usr/share/bash-completion/completions/${_cmd}.${_shell}
}
f.x fd.session

unset _guard
loaded "${BASH_SOURCE}"
