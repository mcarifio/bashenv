#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --url= --pkg= --cmd=
binstall.$(path.basename.part $0 1) \
         --url=https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh \
         --pkg=$(path.basename "$0") \
         -- -y --no-modify-path "$@"
# post install
