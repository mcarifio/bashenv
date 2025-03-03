#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --pkg=${_owner}+${_project} [--cmd=]* --asset=.tar.gz --file='*'
# https://github.com/quantumsheep/sshs/releases/tag/4.6.1
binstall.$(path.basename.part $0 1) \
         --pkg=$(path.basename "$0") \
         --asset=sshs-linux-amd64 \
         --all \
         "$@"
# post install

