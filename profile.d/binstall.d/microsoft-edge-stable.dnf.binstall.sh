#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --import= --repo= --copr= --pkg= --cmd=
binstall.$(path.basename.part $0 1) \
         --import=https://packages.microsoft.com/keys/microsoft.asc \
         --add-repo=https://packages.microsoft.com/yumrepos/edge \
         --pkg=$(path.basename "$0") \
         "$@"
# post install
