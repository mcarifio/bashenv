#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh

_os_release=$(os-release.id)
case ${_os_release} in
    fedora) binstall.dnf --pkg=clang --pkg=lld;;
    ubuntu) ;; # binstall.apt --pkg=... ;;
    *) ;; # >&2 echo "${_os_release} prerequisites for ${_pkg} needed? Continuing..." ;;
esac

# --url= --pkg= --cmd=
binstall.$(path.basename.part $0 1) \
         --url="https://github.com/facebook/buck2/releases/download/latest/buck2-x86_64-unknown-linux-gnu.zst" \
         --pkg=$(path.basename "$0") "$@"
# post install
