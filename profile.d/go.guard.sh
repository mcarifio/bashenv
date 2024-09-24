# creation: guard.mkguard ${_name}
_guard=$(path.basename ${BASH_SOURCE})

# Wrap go if needed.
# go() ( command ${FUNCNAME} "$@"; )
# f.x go


go.docs() (
    set -Eeuo pipefail; shopt -s nullglob
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} "$@" # hard-code urls here if desired
)
f.x go.docs

go.env() {
    : '# called (once) by .bash_profile'
    export GOBIN=${HOME}/.local/bin
}
f.x go.env

go.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    u.have gocomplete && complete -C gocomplete ${_cmd} || return $(u.error "gocomplete missing")
}
f.x go.session

unset _guard
loaded "${BASH_SOURCE}"
