${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

duckdb.env() {
    true || return $(u.error "${FUNCNAME} failed")
}
f.x duckdb.env

duckdb.session() {
    : '# called by .bashrc'
    local -r _shell=${1:-$(u.shell)}
    local -r _cmd=${2:-${FUNCNAME%.*}}
    local -r _completions=/usr/share/bash-completion/completions
    u.map source.if ${_completions}/${_cmd}.${_shell} ${_completions}/${_cmd}
}
f.x duckdb.session
duckdb.session

sourced


