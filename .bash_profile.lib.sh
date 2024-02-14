home() (
    : 'home [${user}] #> the login directory of the optional user.'
    getent passwd ${1:-${SUDO_USER:-${USER}}} | cut -d: -f6
); declare -fx home

# Return the full pathname of the bashenv root directory, usually something like ${HOME}/bashenv.
# Depends on where you placed it however.
eval "bashenv.root() ( echo $(dirname $(realpath ${BASH_SOURCE})); )"; declare -fx bashenv.root

path.login() (
    : 'path.login will return interesting directories under ${HOME}'
    printf '%s:' $(home)/opt/*/current/bin $(home)/.config/*/bin
); declare -fx path.login

path.add() {
    : 'path.add ${folder} [after] ## adds ${folder} to PATH iff not already there'
    case ":${PATH}:" in
        *:"$1":*)
            ;;
        *)
            if [ "$2" = "after" ] ; then
                PATH=$PATH:$1
            else
                PATH=$1:$PATH
            fi
    esac
}; declare -fx path.add


path.walk() (
    : 'path.walk ${folder} [${min} [${max}]] #> all directories under ${folder}'
    local -r _root=${1:-${PWD}}
    local -ri _maxdepth=${2:-1}
    local -ri _mindepth=${3:-1}
    find . -mindepth ${_mindepth} -maxdepth ${_maxdepth} -type d -regex '.*/[^\.]+$'
); declare -fx path.walk

path.pn1() ( realpath -Lms ${1:-${PWD}}; ); declare -fx path.pn1
path.pn() ( _map path.pn1 $* ; ); declare -fx path.pn
# full pathname 1
path.fpn1() ( echo -n ${HOSTNAME}:; realpath -Lms ${1:-${PWD}}; ); declare -fx path.fpn1
# full pathname
path.fpn() ( _map path.fpn1 $* ; ); declare -fx path.fpn


path.md() (
    : 'path.md ## make a directory and return its pathname, e.g cp foo $(path.md /tmp/foo)/bar'
    local _d=$(path.pn1 $1)
    [[ -d "$_d" ]] || mkdir -p ${_d}
    printf "%s" ${_d}
); declare -fx path.md

path.mkcd() {
    local _d=$(path.md $1); [[ -z "${_d}" ]] || cd -Pe ${_d}
}; declare -fx path.mkcd

path.mp() ( local _p=$(printf "%s/%s" $(md $1/..) ${1##*/}); printf ${_p}; ); declare -fx path.mp
path.mpt() ( local _p=$(printf "%s/%s" $(md $1/..) ${1##*/}); touch ${_p}; printf ${_p}; ); declare -fx path.mpt
path.mpcd() ( cd $(dirname $(mp ${1:?'expecting a pathname'})); ); declare -fx path.mpcd

source.all() {
    for _a in $@; do
	source "${_a}" || >&2 echo "'${_a}' => $?" || true
    done
}; declare -fx source.all

source.find() {
    local -r _root="${1:?'expecting a folder'}"
    source.all $(find "${_root}" -regex '[^#]+\.sh$')
}; declare -fx source.find

source.bash_profile.d() {
    source.find $(bashenv.root)/.bash_profile.d
}; declare -fx source.bash_profile.d

source.bashrc.d() {
    source.find $(bashenv.root)/.bashrc.d
}; declare -fx source.bashrc.d

source.bash_completion.d() {
    source.find $(bashenv.root)/.bash_completion.d
}; declare -fx source.bash_completion.d

running.bash() { realpath /proc/$$/exe | grep -Eq 'bash$' || return 0; }; declare -fx running.bash
has() ( &> /dev/null type ${1?:'expecting a command'} || >&2 echo "missing $1"; ); declare -fx has
has.all() ( for _a in "$@"; do has $_a; done; ); declare -fx has.all
