${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

# deno() ( command ${FUNCNAME} "$@"; )
# f.x deno


deno.docs() (
    set -Eeuo pipefail; shopt -s nullglob
    local -nu _docs=${FUNCNAME%.*}_urls # e.g. UV_DOCS
    set -x; xdg-open ${_docs:-} https://docs.deno.com "$@" # hard-code urls here if desired
)
f.x deno.docs

deno.env() {
    : '# called (once) by .bash_profile'
    true || return $(u.error "${FUNCNAME} failed")
}
f.x deno.env

deno.session() {
    : '# called by .bashrc'
    source <(deno completions $(u.shell)
}
f.x deno.session

sourced || true

