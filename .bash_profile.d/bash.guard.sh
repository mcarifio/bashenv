bash.ec() (
    : 'bash.ec ${function-name} => ec +${lineno} ${pathname} # suitable for emacs'
    shopt -s extdebug
    #                ${name} ${lineno} ${pathname}
    local _where=( $(declare -F ${1:?'expecting a function'}) )
    ec +${_where[1]} ${_where[2]} ## emacs format
)
f.complete bash.ec

bash.source() (
    : 'bash.ec ${function-name} => ec +${lineno} ${pathname} # suitable for emacs'
    shopt -s extdebug
    #                ${name} ${lineno} ${pathname}
    local _where=( $(declare -F ${1:?'expecting a function'}) )
    echo ${_where[2]}
)
f.complete bash.source


bash.reload() {
    : 'bash.reload ${function} ## reload the source file that defined ${function}'
    source $(bash.source ${1:?'expecting a function'})
}
f.complete bash.reload

bash.shopt() {
    shopt -s cdable_vars autocd
}
f.complete bash.shopt


export _bash_shopt=${BASHOPTS}
bash.shopt

