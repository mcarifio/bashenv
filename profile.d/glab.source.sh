${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

glab.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x glab.env

glab.session() {
    source <(command glab completion) || u.error "${FUNCNAME} failed" || true
}
f.x glab.session

sourced || true

