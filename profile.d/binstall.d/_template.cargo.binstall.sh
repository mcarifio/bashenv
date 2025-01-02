#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part "$0" 2).source.sh

main() (
    local _kind=$(path.basename.part "$0" 1)
    local -a _pkgs=( $(path.basename "$0") )
    local -a _cmds=()

    _os_release=$(os-release.id)
    case ${_os_release} in
        fedora) ;; # binstall.dnf --pkg=... ;;
        ubuntu) ;; # binstall.apt --pkg=... ;;
        *) ;; # >&2 echo "${_os_release} prerequisites for ${_pkg} needed? Continuing..." ;;
    esac

    binstall.${_kind:-cargo} \
                       $(u.switches pkg ${_pkgs[@]}) \
                       $(u.switches cmd ${_cmds[@]}) \
                       "$@"
    # postinstall here
    true
)

main "$@"


