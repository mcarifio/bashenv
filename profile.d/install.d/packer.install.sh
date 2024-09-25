#!/usr/bin/env bash
set -Eeuo pipefail

# see install.lib.sh for install variants
install() (
    local _distro=$(os.release ID)
    install.${_distro} --add-repo=https://rpm.releases.hashicorp.com/${_distro}/hashicorp.repo packer
    install.check packer
)

install

