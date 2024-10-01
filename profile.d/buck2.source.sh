${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

buck2.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x buck2.env

buck2.session() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x buck2.session

sourced
