${1:-false} || u.have.all $(path.basename.part ${BASH_SOURCE} 0) || return 0

__dotnet.complete() {
    local _command=$1 _word=$2 _previous_word=$3
    local -i _position=${COMP_CWORD} _arg_length=${#COMP_WORDS[@]}
    declare -ig _arg_start _arg_rest
    # TODO mike@carif.io: fix this
    # https://learn.microsoft.com/en-us/dotnet/core/tools/enable-tab-autocomplete
    COMPREPLY=( $(compgen -W "$(dotnet complete --position ${COMP_POINT} "${COMP_LINE}")" -- "${_word}") )
}
declare -fx __dotnet.complete

dotnet.session() {
    complete -F __bashenv_dotnet_bash_complete dotnet || return $(u.error "${FUNCNAME} failed")
}
f.x dotnet.session
dotnet.session

sourced
