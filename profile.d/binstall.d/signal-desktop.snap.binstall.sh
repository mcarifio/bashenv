#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../binstall.source.sh

main() (
    local _kind=$(path.basename.part "$0" 1)
    local -a _pkgs=( $(path.basename "$0") )
    local -a _cmds=()

    binstalld.${kind:-snap} \
                       $(u.switches pkg ${_pkgs[@]}) \
                       $(u.switches cmd ${_cmds[@]}) \
                       "$@"
    # postinstall here
    true
)

main "$@"


