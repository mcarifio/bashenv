#!/usr/bin/env bash
set -Eeuo pipefail; shopt -s nullglob


chk4() ( [[ "${1:?"${FUNCNAME} expects a username"}" = $(path.basename $0) -a "${2:?"${FUNCNAME} expects distro id"}" = $(path.basename $0 1) ]] )

main() (
    local _user=${USER} _id=$(os-release.id)
    chk4 ${_user} ${_id} || return $(u.error "$0 is the wrong bootstrapper for ${_user} release ${_id}")

    local _from='' ## --from=pathname
    local _to="${HOME}" ## --to=pathname
    local -a _parts=()
    
    for _a in "${@}"; do
        local _k="${_a%%=*}"
        local _v="${_a##*=}"
        case "${_a}" in
            # switches
            # --many=*) _many+=( "${_v}" );;
            # --pairs=*) _pairs["$(u.field ${_k})"]="$(u.field ${_v} 1)";;
            --from=*) _from="${_v}";;
            --to=*) _to="${_v}";;
            --part=*) _parts+=( "${_v}" )
            # switch processing
            --) shift; break;; ## explicit stop
            # --*) >&2 echo "${FUNCNAME}: unknown switch ${_a}, stop processing switches"; break;;
            # --*) break;; ## unknown switch, pass it along
            --*) break;; ## unknown switch, pass it along
            *) break;; ## arguments start
        esac
        shift
    done

    [[ -d "${_from}" ]] || return $(u.error "'${_from}' is not a directory")
    (( ${#_parts[@]} )) || _parts= ( .emacs.d .thunderbird .config opt .cargo explore src )
    for _p in ${_parts[@]} do
        local _f="${_from}/${_p}"
        [[ -d "${_f}" ]] || continue
        local _t="{_to}/${_p}"
        # TODO mike@carif.io: add correct switches
        >&2 echo rsync -a ${_f}/ ${_t}
    done              
)

main "$@"
