#!/usr/bin/env bash
# https://github.com/slimtoolkit/slim/releases
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --pkg=${_owner}+${_project} [--cmd=]*
binstall.$(path.basename.part $0 1) \
         --pkg=$(path.basename "$0") \
         --asset=dist_linux.tar.gz \
         --file='dist_linux/*' \
         "$@"
# post install

