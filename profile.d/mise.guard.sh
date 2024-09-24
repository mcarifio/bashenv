# creation: guard.mkguard ${_name}
_guard=$(path.basename ${BASH_SOURCE})

# mise() ( command ${FUNCNAME} "$@"; )
# f.x mise


mise.docs() (
    set -Eeuo pipefail; shopt -s nullglob
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} "$@" # hard-code urls here if desired
)
f.x mise.docs

mise.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x mise.env

mise.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    source <(mise activate $(u.shell))
}
f.x mise.session

unset _guard
loaded "${BASH_SOURCE}"
