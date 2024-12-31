#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/binstalld.lib.sh

main() (
    local _kind=$(path.basename.part "$0" 1)
    local -a _pkgs=( tursodatabase/$(path.basename "$(realpath -Lm "$0")") )
    local -a _cmds=( $(path.basename "$(realpath -Lm "$0")") )

    # prerequisites here
    # local _os_release=$(os-release.id)
    # case ${_os_release} in
    #     fedora) >&2 echo "${_os_release} prerequisites for ${_pkg} needed? Continuing..." ;;
    #     ubuntu) >&2 echo "${_os_release} prerequisites for ${_pkg} needed? Continuing..." ;;
    #     *) >&2 echo "${_os_release} prerequisites for ${_pkg} needed? Continuing..." ;;
    # esac

    # insert pkgs: $(printf -- '--pkg=%s ' ${_pkgs[@]})
    # insert commands: $(printf -- '--cmd=%s ' ${_cmds[@]})
    # note: ~/.config/eget/eget.toml does all the heavy lifting
    binstalld.dispatch --kind=${_kind} \
                       $(printf -- '--pkg=%s ' ${_pkgs[@]}) \
                       $(printf -- '--cmd=%s ' ${_cmds[@]}) \
                       "$@"
    # postinstall here    
)

main "$@"


