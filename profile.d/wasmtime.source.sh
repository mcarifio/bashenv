${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

wasmtime.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x wasmtime.env

wasmtime.session() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x wasmtime.session

wasmtime.installer() (
    set -Eeuo pipefail; # shopt -s nullglob
    # ls colorcodes output
    ls -1 $(bashenv.profiled)/binstall.d/*${FUNCNAME%.*}*.*.binstall.sh
)
f.x wasmtime.installer

sourced || true
