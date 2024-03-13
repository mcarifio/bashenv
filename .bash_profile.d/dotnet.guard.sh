# microsoft dotnet
function __bashenv_dotnet_bash_complete() {
    local _command=$1 _word=$2 _previous_word=$3
    local -i _position=${COMP_CWORD} _arg_length=${#COMP_WORDS[@]}
    declare -ig _arg_start _arg_rest
    # TODO mike@carif.io: fix this
    # https://learn.microsoft.com/en-us/dotnet/core/tools/enable-tab-autocomplete
    COMPREPLY=( $(compgen -W "$(dotnet complete --position ${COMP_POINT} "${COMP_LINE}")" -- "${_word}") )
}
declare -fx __bashenv_dotnet_bash_complete

dotnet.install() (
    : 'dotnet.install # installs microsoft dotnet on this host (if it knows how)'
    __bashenv_dotnet.install.$(os-release.id) "$@"
); declare -fx dotnet.install
__bashenv_dotnet.install.fedora() ( dnf install dotnet; )
declare -fx __bashenv_dotnet.install.fedora
__bashenv_dotnet.install.ubuntu() ( apt install dotnet; )
declare -fx __bashenv_dotnet.install.ubuntu

dotnet.session() {
    complete -F __bashenv_dotnet_bash_complete dotnet
}
declare -fx dotnet.session
dotnet.session
