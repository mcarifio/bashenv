#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/binstalld.lib.sh

main() (
    local _kind=$(path.basename.part "$0" 1)
    local -a _pkgs=( $(path.basename "$(realpath -Lm "$0")") )
    local -a _cmds=( ${_kind}-$(path.basename "$(realpath -Lm "$0")") )

    _os_release=$(os-release.id)
    case ${_os_release} in
        fedora) binstall.dnf --pkg=webkit2gtk4.1-devel --pkg=openssl-devel --pkg=curl --pkg=wget --pkg=file --pkg=libappindicator-gtk3-devel --pkg=librsvg2-devel ;;
        ubuntu) >&2 echo "${_os_release} prerequisites for ${_pkg} needed? Continuing..." ;;
        *) >&2 echo "${_os_release} prerequisites for ${_pkg} needed? Continuing..." ;;
    esac
    
    binstalld.${_kind} \
                       $(u.switches pkg ${_pkgs[@]}) \
                       $(u.switches cmd ${_cmds[@]}) \
                       "$@"
    # postinstall here
    path.alias ${_cmd[0]} tauri
)

main "$@"





