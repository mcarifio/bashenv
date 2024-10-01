${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

netdata.docs() (
    set -Eeuo pipefail
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} "$@" # hard-code urls here if desired
)


netdata.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x netdata.env

netdata.session() {
    : '# called by .bashrc'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x netdata.session

sourced || true

