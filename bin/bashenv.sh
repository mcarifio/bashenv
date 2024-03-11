#!/usr/bin/env bash


doctor() (
    [[ "${FUNCNAME}" = "$1" ]] && shift
    echo ${FUNCNAME} "$@"
)



start() (
    [[ "${FUNCNAME}" = "$1" ]] && shift
    echo ${FUNCNAME} "$@"
)


# dispatch
${1:-start} "$@"
