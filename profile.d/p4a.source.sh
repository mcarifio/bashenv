${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

p4a.docs() (
    set -Eeuo pipefail
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} "https://python-for-android.readthedocs.io/en/latest/"
"$@" # hard-code urls here if desired
)
f.x p4a.docs


p4a.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x p4a.env

p4a.session() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x p4a.session

sourced || true

