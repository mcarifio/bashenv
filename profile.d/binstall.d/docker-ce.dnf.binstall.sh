#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh

main() (
    # kind of installer to run
    local _kind=$(path.basename.part "$0" 1)
    # keys to import with rpm --import
    local -a _imports=()
    # repos to addrepo (urls)
    local -a _repos=( https://download.docker.com/linux/$(os.release ID)/docker-ce.repo )
    # coprs to add in ${owner}/${pkg} format
    local -a _coprs=()
    # packages to install
    local -a _pkgs=( $(path.basename "$0"){,-cli} containerd.io docker-{buildx-plugin,compose-plugin})
    # commands to test after installation
    local -a _cmds=()

    binstall.${_kind:-dnf} \
             $(u.switches import ${_imports[@]}) \
             $(u.switches add-repo ${_repos[@]}) \
             $(u.switches copr ${_coprs[@]}) \
             $(u.switches pkg ${_pkgs[@]}) \
             $(u.switches cmd ${_cmds[@]}) \
             "$@"

    binstall.${_kind:-dnf} --pkg=https://desktop.docker.com/linux/main/amd64/docker-desktop-$(arch).rpm

    # postinstall here
    sudo systemctl enable --now docker
    sudo systemctl enable --now containerd
    sudo usermod -aG docker $USER
    echo "newgrp docker ## next"
)

main "$@"
