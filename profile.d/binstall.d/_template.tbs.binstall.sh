#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/binstalld.lib.sh

main() (
    local _kind=$(path.basename.part "$0" 1)
    local -a _pkgs=( $(path.basename "$(realpath -Lm "$0")") )
    local -a _cmds=()

    # prerequisites here
    # local _os_release=$(os-release.id)
    # case ${_os_release} in
    #     fedora) >&2 echo "${_os_release} prerequisites for ${_pkg} needed? Continuing..." ;;
    #     ubuntu) >&2 echo "${_os_release} prerequisites for ${_pkg} needed? Continuing..." ;;
    #     *) >&2 echo "${_os_release} prerequisites for ${_pkg} needed? Continuing..." ;;
    # esac

    binstalld.dispatch --kind=${_kind} \
                       $(u.switches pkg ${_pkgs[@]}) \
                       $(u.switches cmd ${_cmds[@]}) \
                       "$@"
    # postinstall here    
)

main "$@"


