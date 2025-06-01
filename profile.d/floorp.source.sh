${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0
return 0 # until I figure out how to use it

floorp.env() {
    xdg-settings set default-web-browser floorp.desktop
}
f.x floorp.env

floorp.session() {
    # [[ -n "$SSH_CLIENT" ]] && return 0
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x floorp.session

sourced

