# usage: [guard | source] atuin.guard.sh [--install] [--verbose] [--trace]
_guard=$(path.basename ${BASH_SOURCE})

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

loaded "${BASH_SOURCE}"
