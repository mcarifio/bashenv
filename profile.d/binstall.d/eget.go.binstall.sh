#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --url= --pkg= --cmd=
binstall.$(path.basename.part $0 1) \
         --url="github.com/zyedidia/eget@latest" \
         --pkg=$(path.basename "$0") \
         "$@"
# post install
