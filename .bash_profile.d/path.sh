realpath /proc/$$/exe | grep -Eq 'bash$' || return 0
# taken from /etc/profile because it's later unset and useful.
path.add() {
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
