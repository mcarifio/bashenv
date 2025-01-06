#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --pkg= --cmd=
binstall.$(path.basename.part $0 1) \
         --signed-by=https://packages.microsoft.com/keys/microsoft.asc \
         --component=stable \
         --component=main \
         --uri=https://packages.microsoft.com/repos/edge \
         --pkg=$(path.basename "$0") \
         "$@"
# post install
