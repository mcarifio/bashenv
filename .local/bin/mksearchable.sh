#!/usr/bin/env bash
set -Eeuo pipefail; shopt -s nullglob
[[ "$0" = */bashdb ]] && shift

# make a file tree searchable by creating a locate database at it's root based on the folder's name.
# mksearchable ~/Documents/e creates ~/Documents/e/e.locate.db which can be searched with
#  locate -d ~/Documents/e/e.locate.db ${query}.

# mksearchable --function[=fx] generates a bash function that will conduct the search. This simplies
# knowing various locations and locate switches. Here's the usage: `source <(mksearchable --function=fx ~/Documents/e)`
# This creates the bash function `locate.e` which can be called with query arguments.
# mksearchable --function --name=foo ~/Documents/e names the bash function `foo`.

mksearchable() (
    : '[${_root}] ## generate plocate database at pathname _db of content rooted at pathname _root'
    set -Eeuo pipefail; shopt -s nullglob

    # parse flags
    local -i _regenerate=0
    local _fname='e.locate' _db=''
    
    for _a in "${@}"; do
        case "${_a}" in
            --fname=*) _fname=${_a##*=};;
            --output=*) _db=${_a##*=};;
            --regenerate) _regenerate=1;;
            --) shift; break;;
            --*) return $(u.error "${FUNCNAME} received unknown switch '${_a}', stopping.") 1;;
            *) break;;
        esac
        shift
    done

    local -r _root="${1:-$(realpath -Lm ${0%/*}/..)}"
    [[ -n "${_fname}" ]] || _fname=${_root##*/}.locate
    [[ -n "${_db}" ]] || _db="$(realpath -Lm "${_root}/../${_fname}.db")"

    [[ (( _regenerate )) && -r "${_db}" ]] && { xz --force "${_db}" || true; }
    # index ${_root}
    if [[ ! -r "${_db}" ]]; then
        sudo updatedb --require-visibility yes --add-prunenames '2sort 2sort-manually .attic' --output "${_db}" --database-root "$@" || true
        sudo chown ${USER}:${USER} "${_db}" || true
    fi

    [[ -r "${_db}" ]] && printf '%s() ( locate --database "%s" "$@"; ); f.x %s;' ${_fname:-e.locate} "${_db}" ${_fname}
)

main() (
    mksearchable "$@"
)

main "$@"
