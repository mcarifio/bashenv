#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --url= --version= [--pkg=]+ [--cmd=]*
binstall.$(path.basename.part $0 1) --pkg=$(path.basename "$0") "$@"
# post install
