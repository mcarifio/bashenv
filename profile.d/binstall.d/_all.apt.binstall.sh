#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh

_installer=$(path.basename.part $0 1)
binstall.${_installer} $(binstall.external-switches "$0" uri ppa suite component signed-by pkg cmd) "$@" || \
    exit $(u.warn "$0@${LINENO}: ${_installer} => $?, post install skipped.")
# post install
