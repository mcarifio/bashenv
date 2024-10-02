${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0


trunk.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x trunk.env

trunk.session() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x trunk.session

sourced || true
