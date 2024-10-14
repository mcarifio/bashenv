#!/usr/bin/env bash

sudo rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg

sudo tee -a /etc/yum.repos.d/vscodium.repo << EOF
[gitlab.com_paulcarroty_vscodium_repo]
name=download.vscodium.com
baseurl=https://download.vscodium.com/rpms/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
metadata_expire=1h
EOF

sudo dnf install -y codium

codium --version

# install preferred extensions
_guard=$(realpath -Lm $(dirname $0)/..)/codium.source.sh
[[ -r "${_guard}" ]] || return 0
type -p codium.install-extensions &> /dev/null && codium.install-extensions

