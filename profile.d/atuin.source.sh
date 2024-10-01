${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

atuin.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x atuin.env

atuin.session() {
    [[ -n "$SSH_CLIENT" ]] && return 0
    [[ -f /usr/share/bash-prexec ]] && source /usr/share/bash-prexec
    source <(atuin init bash) || return $(u.error "${FUNCNAME} failed")
}
f.x atuin.session

sourced
