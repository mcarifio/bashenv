#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --pkg= [--cmd=]*
binstall.$(path.basename.part $0 1) \
         --pkg="github.com/caris-events/tunalog@latest" \ 
         "$@"
# post install
