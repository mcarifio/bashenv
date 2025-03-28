#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# [--ppa=]* [--uri=]* [--suite=]* [--component=]* [_components=]* [--signed-by=]* [--pkg=]* [--cmd=*] [--check]
binstall.$(path.basename.part $0 1) \
         --signed-by=https://apt.releases.hashicorp.com/gpg \
         --uri=https://apt.releases.hashicorp.com \
         --suite="$(lsb_release -cs) main" \
         --pkg=$(path.basename "$0") \
         --check "$@"
# post install
