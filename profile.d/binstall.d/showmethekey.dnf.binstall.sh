#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --import= --repo= --copr= --pkg= --cmd=
binstall.$(path.basename.part $0 1) \
         --copr=pesader/showmethekey \
         --pkg=$(path.basename "$0") \
         --cmd=$(path.basename "$0")-cli \
         "$@"
# post install
