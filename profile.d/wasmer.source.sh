${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

wasmer.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x wasmer.env

wasmer.session() {
    source <(wasmer gen-completions $(u.shell))
}
f.x wasmer.session

wasmer.installer() (
    set -Eeuo pipefail
    # ls colorcodes output
    ls -1 $(bashenv.profiled)/binstall.d/*wasmer-cli*.*.binstall.sh
)
f.x wasmer.installer

sourced || true
