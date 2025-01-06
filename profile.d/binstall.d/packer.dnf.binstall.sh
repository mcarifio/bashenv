#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --import= --repo= --copr= --pkg= --cmd=
binstall.$(path.basename.part $0 1) \
         --add-repo="https://rpm.releases.hashicorp.com/$(os.release ID)/hashicorp.repo" \
         --pkg=$(path.basename "$0") \
         "$@"
# post install
