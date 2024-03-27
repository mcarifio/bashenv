direnv.session() {
    source <(direnv hook $(u.shell 2>/dev/null || echo bash)) || return $(u.error "${FUNCNAME} failed")
}
f.x direnv.session
direnv.session

loaded "${BASH_SOURCE}"

