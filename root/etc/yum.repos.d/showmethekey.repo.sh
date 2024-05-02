#!/usr/bin/env bash

# elevate to root
(( $(id -u) )) && exec sudo -E $(realpath ${BASH_SOURCE}) "$@"

install -C ${BASH_SOURCE%%.sh} /etc/yum.profile.d/
rpm-ostree install $(path.basename ${BASH_SOURCE})
rpm-ostree apply-live --allow-replacement && (set -x; showmethekey-cli --version)



