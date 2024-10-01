${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

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
    mkdir -p $(go env GOPATH)
}
f.x go.env

go.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    u.have gocomplete || return $(u.error "gocomplete missing")
    complete -C gocomplete ${_cmd} 
}
f.x go.session

sourced
