#!/usr/bin/env bash
set -Eeuo pipefail; shopt -s nullglob

# inherits _var, _caller contents, no side effects
f() (
    declare -aiI _var
    local -I _caller
    _caller+=" ${FUNCNAME}"
    printf '%s %s ' ${FUNCNAME} ${_caller} >&2; printf '%s ' ${_var[*]} >&2; echo >&2
    _var+=( $1 )
    printf '%s %s ' ${FUNCNAME} ${_caller} >&2; printf '%s ' ${_var[*]} >&2; echo >&2
    g $(( $1 +  $1 ))
    printf '%s %s ' ${FUNCNAME} ${_caller} >&2; printf '%s ' ${_var[*]} >&2; echo >&2
)

# inherits _var contents, no side effects
g() (
    declare -aiI _var
    local -I _caller
    _caller+=" ${FUNCNAME}"
    printf '%s %s ' ${FUNCNAME} ${_caller} >&2; printf '%s ' ${_var[*]} >&2; echo >&2
    _var+=( $1 )
    printf '%s %s ' ${FUNCNAME} ${_caller} >&2; printf '%s ' ${_var[*]} >&2; echo >&2
)


main() (
    declare -ai _var=(100)
    local _caller=${FUNCNAME}
    printf '%s %s ' ${FUNCNAME} ${_caller} >&2; printf '%s ' ${_var[*]} >&2; echo >&2
    f 1
    printf '%s %s ' ${FUNCNAME} ${_caller} >&2; printf '%s ' ${_var[*]} >&2; echo >&2
)

main "${*:-}"
