#!/usr/bin/env bash


doctor() (
    [[ "${FUNCNAME}" = "$1" ]] && shift
    echo ${FUNCNAME} "$@"
)



start() (
    [[ "${FUNCNAME}" = "$1" ]] && shift
    declare -A _flags=( [entry]=${FUNCNAME} [verbose]=0 )
    declare -a _args=()
    _parse _flags _args "$@"
    echo ${_flags[verbose]}
    echo ${_flags[foo]}
    echo "${_args[@]}"
)


# all entry points parse arguments first
_parse() {
    declare -n _Aref=$1; shift
    declare -n _aref=$1; shift
    for _a in "$@"; do
	case "${_a}" in
	    --) shift;break;;
	    --*=*) [[ "${_a}" =~ ^--([^=]+)=(.*)$ ]] && _Aref[${BASH_REMATCH[1]}]="${BASH_REMATCH[1]}";;
	    --*) [[ "${_a}" =~ ^--(.+)$ ]] && _Aref[${BASH_REMATCH[1]}]=1;;
	    *) break;;
	esac
	shift
    done
    _aref=( "$@" )
}

# dispatch
${1:-start} "$@"
