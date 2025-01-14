#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# [--uri=]* [--suite=]* [--component=]* [_components=]* [--signed-by=]* [--pkg=]* [--cmd=*]
binstall.$(path.basename.part $0 1) \
         --pkg=$(path.basename "$0") \
         --check "$@"
# post install
