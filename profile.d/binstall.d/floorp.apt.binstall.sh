#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# [--ppa=]* [--uri=]* [--suite=]* [--component=]* [_components=]* [--signed-by=]* [--pkg=]* [--cmd=*] [--check]
binstall.$(path.basename.part $0 1) \
         --signed-by=https://ppa.floorp.app/KEY.gpg \
         --uri=https://ppa.floorp.app/$(dpkg --print-architecture)  \
         --component="./" \
         --pkg=$(path.basename "$0")
# post install
