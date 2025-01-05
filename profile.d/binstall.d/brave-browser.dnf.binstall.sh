#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --import= --repo= --copr= --pkg= --cmd=
binstall.$(path.basename.part $0 1) \
         --import=https://brave-browser-rpm-release.s3.brave.com/brave-core.asc \
         --repo=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo \
         --pkg=$(path.basename "$0") "$@"
# post install
