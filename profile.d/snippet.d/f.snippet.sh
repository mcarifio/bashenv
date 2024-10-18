some.thing() (
    set -Eeuo pipefail; shopt -s nullglob

    # switches: initialize defaults
    local -i _bool=0
    # _var required, see check below
    local _var='_var' _varo='_varo' _doo=default # no _do
    local -a _many=()
    local -A _pairs=()
    local -A _passthru # unknown switches, passed through
    echo "** ${FUNCNAME} keywords initialized:" >&2
    declare -p _bool _var _varo _doo _many _pairs >&2


    # parse switches
    for _a in "${@}"; do
        case "${_a}" in
            --bool) _bool=1;; ## turn _bool on
            --var=*) _var="${_a##*=}";;
            --varo=*) _varo="${_a##*=}";;
	    --do=*) _do="${_a##*=}";; # assign undefined variable
            --doo=*) _doo="${_a##*=}";;
            --many=*) _many+=( "${_a##*=}" );;
            --pairs=*) _pairs["$(u.field ${_a##*=})"]="$(u.field ${_a##*=} 1)";;
            --*) _passthru+=( "${_a}" );; ## break on unknown switch, pass it along

            --) shift; break;;
            --*) _passthru+=( "${_a}" );; ## break on unknown switch, pass it along
            # --*) >&2 echo "${FUNCNAME}: unknown switch ${_a}, stop processing switches"; break;;
            # --*) return $(u.error "${FUNCNAME} unknown switch '${_a}', stopping");; ## error on unknown switch
            *) break;;
        esac
        shift
    done

    echo "** ${FUNCNAME} args parsed" >&2
    declare -p _bool _var _varo _doo _many _pairs _passthru >&2
    

    # check args
    echo "** ${FUNCNAME} check args" >&2
    [[ -z "${_var:-}" ]] && { echo "${FUNCNAME} _var has no required value, use --var=\${something}"; echo "return here"; } >&2
    declare -p _var >&2
    # arg checks
    (( _bool > -1 )) || return $(u.error "${FUNCNAME} _bool is ${_bool}, expecting _bool > -1")
    declare -p _bool >&2

    
    # body
    echo "@: $@" >&2
    echo "** ${FUNCNAME} return" >&2
    echo ${USER}
)
__complete.some.thing() {
    local _command=$1 _word=$2 _previous_word=$3
    local -i _position=${COMP_CWORD} _arg_length=${#COMP_WORDS[@]}
    COMPREPLY=( $(compgen -f "$(bashenv.binstalld)/${_word##*/}") )
    # declare -p COMPREPLY >&2
}
f.complete some.thing

