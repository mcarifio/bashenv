#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# [--import=]* [--repo=]* [--copr=]* [--pkg=]* [--cmd=]*
binstall.$(path.basename.part $0 1) \
         --pkg="https://releases.warp.dev/stable/v0.2024.12.18.08.02.stable_03/warp-terminal-v0.2024.12.18.08.02.stable_03-1.x86_64.rpm" \
         "$@"
# post install
