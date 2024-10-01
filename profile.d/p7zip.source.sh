# creation: guard.mkguard ${_name}
_guard=$(path.basename ${BASH_SOURCE})

# Wrap p7zip if needed.
# p7zip() ( command ${FUNCNAME} "$@"; )
# f.x p7zip


p7zip.docs() (
    set -Eeuo pipefail; shopt -s nullglob
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} "$@" # hard-code urls here if desired
)
f.x p7zip.docs

p7zip.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x p7zip.env

p7zip.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    true || return $(u.error "${FUNCNAME} failed for cmd ${_cmd} and shell ${_shell}")
}
f.x p7zip.session

unset _guard
loaded "${BASH_SOURCE}"
