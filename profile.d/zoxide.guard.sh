# creation: guard.mkguard ${_name}
_guard=$(path.basename ${BASH_SOURCE})

# Wrap zoxide if needed.
# zoxide() ( command ${FUNCNAME} "$@"; )
# f.x zoxide


zoxide.docs() (
    set -Eeuo pipefail; shopt -s nullglob
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} "$@" # hard-code urls here if desired
)
f.x zoxide.docs

zoxide.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x zoxide.env

zoxide.session() {
    : '# called by .bashrc'
    source <(${FUNCNAME%.*} init $(u.shell))
}
f.x zoxide.session

unset _guard
loaded "${BASH_SOURCE}"
