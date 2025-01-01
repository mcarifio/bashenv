#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/binstalld.lib.sh

# https://tailscale.com/kb/1511/install-fedora-2
main() (
    # local -a _imports=()
    local -a _imports=()

    # local -a _repos=()
    local _id=$(os-release.id)
    local -a _repos=("https://pkgs.tailscale.com/stable/${_id}/tailscale.repo")

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
    sudo systemctl enable --now tailscaled
    systemctl status tailscaled
)

main "$@"


