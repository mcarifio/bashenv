#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh

main() (
    # kind of installer to run
    local _kind=$(path.basename.part "$0" 1)
    # keys to import with rpm --import
    local -a _imports=( https://packages.microsoft.com/keys/microsoft.asc )
    # repos to addrepo (urls)
    local -a _repos=( https://packages.microsoft.com/yumrepos/vscode )
    # coprs to add in ${owner}/${pkg} format
    local -a _coprs=()
    # packages to install
    local -a _pkgs=( $(path.basename "$0") )
    # commands to test after installation
    local -a _cmds=()

    binstall.${_kind:-dnf} \
             $(u.switches import ${_imports[@]}) \
             $(u.switches add-repo ${_repos[@]}) \
             $(u.switches copr ${_coprs[@]}) \
             $(u.switches pkg ${_pkgs[@]}) \
             $(u.switches cmd ${_cmds[@]}) \
             "$@"

    # postinstall here
    true
)

main "$@"
