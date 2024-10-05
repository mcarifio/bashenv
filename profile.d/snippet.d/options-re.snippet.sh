#!/usr/bin/env bash
# set -x
set -Eeuo pipefail; shopt -s nullglob

# on.return() { local -i _status=$?; printf '* => %s *\n' ${_status} >&2; return ${_status}; }
# trap on.return RETURN

example.options() (
    set -Eeuo pipefail; shopt -s nullglob
    echo -e "\n\n** ${FUNCNAME} unparsed args: " "$@" >&2 

    local -A _known=(
        [bool]=0
        [var]='default_var'
        [varo]='default_varo'
        [doo]='default doo'
        [dot.dot]=..
    )
    local -a _many
    local -A _pairs
                             
   
    echo "** ${FUNCNAME} keywords initialized:" >&2
    declare -p _known _many _pairs >&2

    for _a in "${@}"; do
        case "${_a}" in
            ## flags that accumulate values
            ## --many=1 --many=2 --many=3 # _many=(1 2 3)
            --many=*) _many+=( "${_a##*=}" );;
            ## --pairs=x:1 --pairs=y:2 --pairs=z:3 # _pairs=( [x]=1 [y]=2 [z]=3 )
            --pairs=*) _pairs["$(u.field ${_a##*=})"]="$(u.field ${_a##*=} 1)";;

            --) shift; break;;
            --*) [[ "${_a}" =~ ^--(([^=]+)?(=(.+))?)$ ]] || return $(u.error "${FUNCNAME} re failed")
                 local _key="${BASH_REMATCH[2]}" _value="${BASH_REMATCH[4]:-1}"
                 [[ -z "${_key}" && -n "${_value}" ]] && return $(u.error "${FUNCNAME} switch '${_a}' has no key")
                 declare -p _key _value >&2
                 ## [[ -v _known["${_key}"] ]] && _known["${_key}"]="${_value}" || _unknown+="${_a} "  ## accumulate unknown switches
                 [[ -v _known["${_key}"] ]] && _known["${_key}"]="${_value}" || return $(u.error "${FUNCNAME} '--${_key}' is not a valid switch");;
            *) break;;
        esac
        shift
    done

    echo "** ${FUNCNAME} args parsed" >&2
    declare -p _known _many _pairs >&2

    echo "** ${FUNCNAME} check args" >&2
    [[ -v _known[var] ]] || return $(u.error "${FUNCNAME} --var=something is required")

    (( _known[bool] > -1 )) || return $(u.error "${FUNCNAME} _bool is ${_bool}, expecting _bool > -1")
    
    echo "** ${FUNCNAME} all options" >&2
    declare -p _known _many _pairs >&2
    
    # assign remaining arguments
    local _first="${1:?\"${FUNCNAME} expecting first argument\"}"; shift
    local _second="${1:?\"${FUNCNAME} expecting second argument\"}"; shift
    # _rest is everything unassigned, for completeness
    local -a _rest=( "$@" )

    echo "** ${FUNCNAME} all args" >&2
    declare -p _first _second _rest >&2

    # body
    echo "** ${FUNCNAME} body" >&2
    echo "** ${FUNCNAME} return" >&2
    echo ${USER}
)

# set -x
# exit 1

simple.options() (
    set -Eeuo pipefail; shopt -s nullglob
    # known flags with default values
    local -A _known=(
        [bool]=0
        [var]='default_var' ## required
        [varo]='default_varo'
        [doo]='default doo'
        [dot.dot]=..
    )
    # unknown flags that are acculated and passed through in the body
    local _unknown=''

    for _a in "${@}"; do
        case "${_a}" in
            --) shift; break;;
            --*) [[ "${_a}" =~ ^--(([^=]+)?(=(.+))?)$ ]] || return $(u.error "${FUNCNAME} re failed")
                 local _key="${BASH_REMATCH[2]}" _value="${BASH_REMATCH[4]:-1}"
                 [[ -z "${_key}" && -n "${_value}" ]] && return $(u.error "${FUNCNAME} switch '${_a}' has no key")
                 ## [[ -v _known["${_key}"] ]] && _known["${_key}"]="${_value}" || return $(u.error "${FUNCNAME} '--${_key}' is not a valid switch");;
                 [[ -v _known["${_key}"] ]] && _known["${_key}"]="${_value}" || _unknown+="${_a} ";;
            *) break;;
        esac
        shift
    done

    # var required
    [[ -v _known[var] ]] || return $(u.error "${FUNCNAME} --var=something is required")
    # bool must be in range
    (( _known[bool] > -1 )) || return $(u.error "${FUNCNAME} _bool is ${_bool}, expecting _bool > -1")
    
    # positional arguments: first two are required
    local _first="${1:?\"${FUNCNAME} expecting first argument\"}"; shift
    local _second="${1:?\"${FUNCNAME} expecting second argument\"}"; shift
    # _rest is everything unassigned, for completeness
    local -a _rest=( "$@" )

    # body
    declare -p _known _unknown _first _second _rest
)

    
all() (
    set +Ee
    set -uo pipefail; shopt -s nullglob
    # succeeds
    local _result=''; _result=$(example.options no options ${LINENO}); test $? = 0 -a "${_result}" = ${USER} || echo "failed ${LINENO}" >&2
    _result=''; _result=$(example.options --bool just bool  ${LINENO}}); test $? = 0 -a "${_result}" = ${USER} || echo "failed ${LINENO}" >&2
    _result=''; _result=$(example.options --do=something just something else ${LINENO}); test $? = 0 -a "${_result}" = ${USER} || echo "failed ${LINENO}" >&2
    _result=''; _result=$(example.options --var=${USER} just var ${LINENO}); test $? = 0 -a "${_result}" = ${USER} || echo "failed ${LINENO}" >&2
    _result=''; _result=$(example.options --varo=oh just varo ${LINENO}); test $? = 0 -a "${_result}" = ${USER} || echo "failed ${LINENO}" >&2
    _result=''; _result=$(example.options --many=1 --varo=oh --many=2 --many=3 just varo ${LINENO})
    test $? = 0 -a "${_result}" = ${USER} || echo "failed ${LINENO}" >&2
    _result=''; _result=$(example.options --pairs=two:2 --varo=oh --pairs=one:1 just varo ${LINENO})
    test $? = 0 -a "${_result}" = ${USER} || echo "failed ${LINENO}" >&2    
    _result=''; _result=$(example.options --pairs=one:two:three --varo=oh just varo ${LINENO}); test $? = 0 -a "${_result}" = ${USER} || echo "failed ${LINENO}" >&2
    

    # fails
    _result=''; _result=$(example.options --doo='doo doo' ${LINENO}); test $? != 0 -a -z "${_result}" || echo "failed ${LINENO}" >&2
    _result=''; _result=$(example.options --doo='doo doo' ${LINENO}); test $? != 0 -a -z "${_result}"  || echo "failed ${LINENO}" >&2
    _result=''; _result=$(example.options --doo='doo doo' ${LINENO}); test $? != 0 -a -z "${_result}"  || echo "failed ${LINENO}" >&2
    _result=''; _result=$(example.options --=something ${LINENO}); test $? != 0 -a -z "${_result}"  || echo "failed ${LINENO}" >&2
    
    # succeeds
    _result=''; _result=$(example.options --var=100 --bool --do=something+else --varo=200 --doo=dowhop all options ${LINENO}); test $? = 0 -a "${_result}" = ${USER} || echo "failed ${LINENO}" >&2
    _result=''; _result=$(example.options --bool -- --var=100 short circuit  ${LINENO}); test $? = 0 -a "${_result}" = ${USER} || echo "failed ${LINENO}" >&2
    _result=''; _result=$(example.options --bool --dot.dot=dot short circuit  ${LINENO}); test $? = 0 -a "${_result}" = ${USER} || echo "failed ${LINENO}" >&2

)

all




