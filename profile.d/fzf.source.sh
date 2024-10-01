# creation: guard.mkguard ${_name}
_guard=$(path.basename ${BASH_SOURCE})

# Wrap fzf if needed.
# fzf() ( command ${FUNCNAME} "$@"; )
# f.x fzf


fzf.docs() (
    set -Eeuo pipefail; shopt -s nullglob
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} "$@" # hard-code urls here if desired
)
f.x fzf.docs

fzf.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x fzf.env

fzf.session() {
    : '# called by .bashrc'
    source <(${FUNCNAME%.*} --$(u.shell))
}
f.x fzf.session

unset _guard
loaded "${BASH_SOURCE}"
