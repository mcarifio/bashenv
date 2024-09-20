#!/usr/bin/env bash

# make a file tree searchable by creating a locate database at it's root based on the folder's name.
# mksearchable ~/Documents/e creates ~/Documents/e/e.locate.db which can be searched with
#  locate -d ~/Documents/e/e.locate.db ${query}.

# mksearchable --function[=fx] generates a bash function that will conduct the search. This simplies
# knowing various locations and locate switches. Here's the usage: `source <(mksearchable --function=fx ~/Documents/e)`
# This creates the bash function `locate.e` which can be called with query arguments.
# mksearchable --function --name=foo ~/Documents/e names the bash function `foo`.

mksearchable() (
    set -Eeuo pipefail; shopt -s nullglob

    # parse flags
    local -i _function=0 _fx=0 _regenerate=0
    local _name='' _db=''
    
    if (( ${#@} )) ; then
        for _a in "${@}"; do
            case "${_a}" in
		--function) _function=1;;
                --function=*) _function=1; _fx=1;;
                --name=*) _name=${_a##*=};;
                --regenerate) _regenerate=1;;
                --db=*) _db=${_a##*=};;
                --) shift; break;;
                *) break;;
            esac
            shift
        done
    fi

    local -r _root="${1:-$(realpath -Lm ${0%/*}/..)}"; shift || true
    [[ -z "${_name}" ]] && _name=${_root##*/}
    local -r _fname=${_name}.locate
    [[ -z "${_db}" ]] && _db="${_root}/${_name}.locate.db}"

    # index ${_root}
    [[ ! -r "${_db}" || (( _regenerate )) ]] && updatedb --require-visibility yes --output "${_db}" --database-root "${_root}"

    if (( _function )); then
        printf '%s() ( locate --database "%s" "$@"; );' ${_fname} "${_db}"
        (( _fx )) && printf 'declare -fx %s;' ${_fname}
        echo
    else
        echo "${_db}"
    fi    
)

main() (
    (( ${#@} )) && mksearchable "$@" || mksearchable --function=fx
)

# usage: source <(mksearchable --function=fx [${_root}])
main "$@"
