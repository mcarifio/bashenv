#!/usr/bin/env bash
# set -x
set -Eeuo pipefail; shopt -s nullglob

# on.return() { local -i _status=$?; printf '* => %s *\n' ${_status} >&2; return ${_status}; }
# trap on.return RETURN

example.options() (
    set -Eeuo pipefail; shopt -s nullglob
    echo -e "\n\n** ${FUNCNAME} unparsed args: " "$@" >&2 

    local -i _bool=0
    # _var required, see check below
    local _var='_var' _varo='_varo' _doo=default # no _do
    local -a _many=()
    local -A _pairs=()
    echo "** ${FUNCNAME} keywords initialized:" >&2
    declare -p _bool _var _varo _doo _many _pairs >&2

    for _a in "${@}"; do
        case "${_a}" in
            --bool) _bool=1;; ## turn _bool on
            --var=*) _var="${_a##*=}";;
            --varo=*) _varo="${_a##*=}";;
	    --do=*) _do="${_a##*=}";; # assign undefined variable
            --doo=*) _doo="${_a##*=}";;
            --many=*) _many+=( "${_a##*=}" );;
            --pairs=*) _pairs["$(u.field ${_a##*=})"]="$(u.field ${_a##*=} 1)";;
            --) shift; break;;
            # --*) break;; ## break on unknown switch, pass it along
            --*) >&2 echo "${FUNCNAME}: unknown switch ${_a}, stop processing switches"; break;;
            # --*) return $(u.error "${FUNCNAME} unknown switch "${_a}", stoppping") ## error on unknown switch
            *) break;;
        esac
        shift
    done

    echo "** ${FUNCNAME} args parsed" >&2
    declare -p _bool _var _varo _doo _many _pairs >&2

    echo "** ${FUNCNAME} check args" >&2
    [[ -z "${_var:-}" ]] && { echo "${FUNCNAME} _var has no required value, use --var=\${something}"; echo "return here"; } >&2
    declare -p _var >&2
    # arg checks
    (( _bool > -1 )) || return $(u.error "${FUNCNAME} _bool is ${_bool}, expecting _bool > -1")
    declare -p _bool >&2
    
    echo "** ${FUNCNAME} all options" >&2
    declare -p _bool >&2
    declare -p _var >&2
    declare -p _varo >&2
    # declare -p _do >&2
    declare -p _doo >&2
    declare -p _many >&2
    declare -p _pairs >&2
    
    # assign remaining arguments
    local _first="${1:?\"${FUNCNAME} expecting first argument\"}"; shift
    declare -p _first >&2
    
    local _second="${1:?\"${FUNCNAME} expecting second argument\"}"; shift
    declare -p _second >&2

    # _rest is everything unassigned, for completeness
    local -a _rest=( "$@" )
    declare -p _rest >&2

    echo "** ${FUNCNAME} all args" >&2
    declare -p _first >&2
    declare -p _second >&2
    declare -p _rest >&2    

    # body
    echo "** ${FUNCNAME} body" >&2
    declare -p _bool >&2
    declare -p _var >&2
    declare -p _varo >&2
    declare -p _doo >&2
    declare -p _many >&2
    declare -p _pairs >&2
    declare -p _first >&2
    declare -p _second >&2
    declare -p _rest >&2
    echo "@: $@" >&2
    echo "** ${FUNCNAME} return" >&2
    echo ${USER}
)

# set -x
# exit 1

    
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
    
    # succeeds
    _result=''; _result=$(example.options --var=100 --bool --do=something+else --varo=200 --doo=dowhop all options ${LINENO}); test $? = 0 -a "${_result}" = ${USER} || echo "failed ${LINENO}" >&2
    _result=''; _result=$(example.options --bool -- --var=100 short circuit  ${LINENO}); test $? = 0 -a "${_result}" = ${USER} || echo "failed ${LINENO}" >&2
)

all




