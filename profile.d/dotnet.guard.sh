# microsoft dotnet
# usage: [guard | source] dotnet.guard.sh [--install] [--verbose] [--trace]
_guard=$(path.basename ${BASH_SOURCE})
declare -A _option=([install]=0 [verbose]=0 [trace]=0)
_undo=''; trap -- 'eval ${_undo}; unset _option _undo; trap -- - RETURN' RETURN
local -a _rest=( $(u.parse _option "$@") )
if (( ${_option[trace]} )) && ! bashenv.is.tracing; then
    _undo+='set +x;'
    set -x
fi
if (( ${_option[install]} )); then
    if u.have ${_guard}; then
        >&2 echo ${_guard} already installed
    else
        case "$(os-release.id)" in
            fedora) dnf install dotnet;;
            ubuntu) sudo command apt install -y dotnet;;
            *) u.bad "${BASH_SOURCE} --install unknown for $(os-release.id)"
        esac         
    fi
fi


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

loaded "${BASH_SOURCE}"
