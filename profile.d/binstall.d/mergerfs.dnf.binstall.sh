#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh

main() (
    local _kind=$(path.basename.part "$0" 1)
    local -a _pkgs=( $(dnf.gh-rpm trapexit/mergerfs) )
    (( ${#_pkgs[@]} )) || return $(u.error "${BASH_SOURCE}:${FUNCNAME} no packages?")
    local -a _cmds=()

    # prerequisites here
    # local _os_release=$(os-release.id)
    # case ${_os_release} in
    #     fedora) >&2 echo "${_os_release} prerequisites for ${_pkg} needed? Continuing..." ;;
    #     ubuntu) >&2 echo "${_os_release} prerequisites for ${_pkg} needed? Continuing..." ;;
    #     *) >&2 echo "${_os_release} prerequisites for ${_pkg} needed? Continuing..." ;;
    # esac

    # insert pkgs: $(printf -- '--pkg=%s ' ${_pkgs[@]})
    # insert commands: $(printf -- '--cmd=%s ' ${_cmds[@]})
    binstalld.dispatch --kind=${_kind} \
                       $(printf -- '--pkg=%s ' ${_pkgs[@]}) \
                       "$@"
    # postinstall here    
)

main "$@"


