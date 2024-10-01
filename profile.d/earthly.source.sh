${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

earthly.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x earthly.env

earthly.session() {
    earthly bootstrap --with-autocomplete
}
f.x earthly.session

sourced || true

