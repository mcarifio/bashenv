#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh

# https://forgejo.org/ https://forgejo.org/docs/latest/ https://codeberg.org/forgejo/forgejo/releases https://codeberg.org/forgejo/-/packages/container

_os_release=$(os-release.id)
case ${_os_release} in
    fedora) ;; # binstall.dnf --pkg=... ;;
    ubuntu) ;; # binstall.apt --pkg=... ;;
    *) ;; # >&2 echo "${_os_release} prerequisites for ${_pkg} needed? Continuing..." ;;
esac

# --url= --pkg= --cmd=
binstall.$(path.basename.part $0 1) \
         --url="https://codeberg.org/forgejo/forgejo/releases/download/v9.0.3/forgejo-9.0.3-linux-amd64.xz" \
         --pkg=$(path.basename "$0") \
         "$@"
# post install

