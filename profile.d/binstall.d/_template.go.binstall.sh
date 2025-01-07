#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --pkg= [--cmd=]*
binstall.$(path.basename.part $0 1) \
         --pkg=$(u.error "$0 expecting --pkg=\${url}" 1) \ # e.g. github.com/openrdap/rdap/cmd/rdap@master
         "$@"
# post install
