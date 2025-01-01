#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/binstalld.lib.sh

main() (
    # local -a _imports=()
    local -a _imports=()

    # local -a _repos=()
    local -a _repos=()

    # local -a _coprs=()
    local -a _coprs=()

    # local -a _pkgs=( $(path.basename "$(realpath -Lm "$0")") )
    local -a _pkgs=( $(path.basename "$(realpath -Lm "$0")") )

    # local -a _cmds=() # dnf will usually get the commands from the .rpm itself
    local -a _cmds=() # dnf will usually get the commands from the .rpm itself

    binstall.dnf \
             $(u.switches import ${_imports[@]}) \
             $(u.switches add-repo ${_repos[@]}) \
             $(u.switches copr ${_coprs[@]}) \
             $(u.switches pkg ${_pkgs[@]}) \
             $(u.switches cmd ${_cmds[@]}) \
             "$@"

    # postinstall here    
)

main "$@"


