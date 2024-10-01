${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

bash.source() (
    : 'bash.ec ${function-name} => ec +${lineno} ${pathname} # suitable for emacs'
    shopt -s extdebug
    #                ${name} ${lineno} ${pathname}
    local _where=( $(declare -F ${1:?'expecting a function'}) )
    echo ${_where[2]}
)
f.x bash.source

bash.reload() {
    : 'bash.reload ${function} ## reload the source file that defined ${function}'
    source $(bash.source ${1:?'expecting a function'})
}
f.x bash.reload

bash.shopt() {
    shopt -s cdable_vars autocd
}
f.x bash.shopt


export _bash_shopt=${BASHOPTS}
bash.shopt

sourced

