#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh

_os_release=$(os-release.id)
case ${_os_release} in
    fedora) ;; # binstall.dnf --pkg=... ;;
    ubuntu) $(u.here)/librust-openssl-dev.apt.binstall.sh;;
    *) ;; # >&2 echo "${_os_release} prerequisites for ${_pkg} needed? Continuing..." ;;
esac

# --pkg= --cmd=
binstall.$(path.basename.part $0 1) \
         --pkg=$(path.basename "$0") \
         --all-features "$@"
# post install
