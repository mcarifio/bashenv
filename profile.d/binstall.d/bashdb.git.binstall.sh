#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh

_os_release=$(os-release.id)
case ${_os_release} in
    fedora) binstall.dnf --pkg=git --pkg=autoconf --pkg=automake --pkg=texinfo --pkg=texi2html --pkg=make;;
    ubuntu) ;; # binstall.apt --pkg=... ;;
    *) ;; # >&2 echo "${_os_release} prerequisites for ${_pkg} needed? Continuing..." ;;
esac

binstall.$(path.basename.part $0 1) --url=https://github.com/rocky/bashdb --pkg="$(path.basename "$0")" "$@"

