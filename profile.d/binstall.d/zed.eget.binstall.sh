#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/binstalld.lib.sh

main() (
    local _kind=$(path.basename.part "$0" 1)
    local -a _pkgs=( $(path.basename "$(realpath -Lm "$0")") )
    local _target=~/opt/$(path.basename "$(realpath -Lm "$0")")

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
                       --to="${_target}" --all "$@"
    # postinstall here
    local _zed_app="${_target}/zed.app"
    [[ -d  "${_zed_app}" ]] || return $(u.error "${BASH_SOURCE} expecting ${_zed_app}")
    ln -srf "${_zed_app}" "${_zed_app}/../current"
)

main "$@"


