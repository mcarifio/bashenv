#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --pkg=${_owner}+${_project} [--cmd=]* --asset=.tar.gz --file='*'
binstall.$(path.basename.part $0 1) \
         --pkg=$(path.basename "$0") \
         --asset=.tar.gz \
         --all \
         "$@"
# post install

