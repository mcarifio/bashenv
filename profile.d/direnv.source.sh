${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

direnv.session() {
    source <(direnv hook $(u.shell)) || return $(u.error "${FUNCNAME} failed")
}
f.x direnv.session
direnv.session

sourced


