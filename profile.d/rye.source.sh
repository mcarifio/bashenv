${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

rye.docs() (
    set -Eeuo pipefail; shopt -s nullglob
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} https://rye.astral.sh/ "$@" # hard-code urls here if desired
)
f.x rye.docs


rye.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x rye.env

rye.session() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x rye.session

rye.installer() ( ls -1 $(bashenv.profiled)/binstall.d/*${FUNCNAME%.*}*.*.binstall.sh; )

sourced || true

