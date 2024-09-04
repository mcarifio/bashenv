#!/usr/bin/env bash
set -Eeuo pipefail

# see install.lib.sh for install variants
install() (
    local _distro=$(os.release ID)
    install.${_distro} --import=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg --add-repo=https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-$(arch) google-cloud-cli libxcrypt-compat.$(arch)
    install.check gcloud
)

install

