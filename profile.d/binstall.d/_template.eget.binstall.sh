#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --pkg=${_owner}+${_project} [--cmd=]*
binstall.$(path.basename.part $0 1) \
         --pkg=$(path.basename "$0") \
         "$@"
# post install

