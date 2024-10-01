${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

pkgx.docs() (
    set -Eeuo pipefail
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} "$@" https://docs.pkgx.sh/
)
f.x pkgx.docs

pkgx.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x pkgx.env

pkgx.session() {
    source <(pkgx --shellcode) || return $(u.error "${FUNCNAME} failed")
}
f.x pkgx.session

sourced || true

