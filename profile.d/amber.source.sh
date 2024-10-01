${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

amber.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x amber.env

amber.session() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x amber.session

sourced
