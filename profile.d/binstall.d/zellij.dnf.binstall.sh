#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh

# https://github.com/zellij-org/zellij/blob/main/docs/THIRD_PARTY_INSTALL.md#fedora-linux
# [--import=]* [--repo=]* [--copr=]* [--pkg=]* [--cmd=]*
binstall.$(path.basename.part $0 1) \
         --copr=varlad/zellij \
         --pkg=$(path.basename "$0") \
         "$@"
# post install
