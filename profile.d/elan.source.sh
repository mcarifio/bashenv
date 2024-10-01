path.add "${HOME}/.elan/bin"
${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

elan.session() {
    : '# called by .bashrc'
    source <(elan completions $(u.shell))
}
f.x elan.session

sourced

