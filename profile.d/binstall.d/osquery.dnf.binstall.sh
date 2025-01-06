#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --import= --repo= --copr= --pkg= --cmd=
binstall.$(path.basename.part $0 1) \
         --import=https://pkg.osquery.io/rpm/GPG \
         --add-repo=https://pkg.osquery.io/rpm/osquery-s3-rpm.repo \
         --pkg=$(path.basename "$0") \
         "$@"
# post install
