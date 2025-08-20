#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# [--ppa=]* [--uri=]* [--suite=]* [--component=]* [_components=]* [--signed-by=]* [--pkg=]* [--cmd=*] [--check]
binstall.$(path.basename.part $0 1) \
         --signed-by=https://apt.fury.io/nushell/gpg.key \
         --uri=https://apt.fury.io/nushell/ \
         --suite=/ \
         --pkg=$(path.basename "$0") \
         --check nu
# post install
