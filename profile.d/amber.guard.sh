# usage: [guard | source] amber.guard.sh [--install] [--verbose] [--trace]
_guard=$(path.basename ${BASH_SOURCE})

amber.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x amber.env

amber.session() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x amber.session

unset _guard
loaded "${BASH_SOURCE}"
