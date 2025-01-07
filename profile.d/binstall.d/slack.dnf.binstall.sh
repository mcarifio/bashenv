#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --import= --repo= --copr= --pkg= --cmd=
binstall.$(path.basename.part $0 1) \
         --pkg="https://downloads.slack-edge.com/desktop-releases/linux/x64/4.39.95/slack-4.39.95-0.1.el8.x86_64.rpm" \
         "$@"
# post install
