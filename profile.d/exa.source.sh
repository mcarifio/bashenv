${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

unalias ls &> /dev/null || true
ls() ( exa "$@"; )
f.x ls

exa.docs() (
    set -Eeuo pipefail; shopt -s nullglob
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    xdg-open ${_docs:-} https://the.exa.website/ "$@" # hard-code urls here if desired
)
f.x exa.docs

exa.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x exa.env

exa.session() {
    : '# called by .bashrc'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x exa.session

sourced || true
