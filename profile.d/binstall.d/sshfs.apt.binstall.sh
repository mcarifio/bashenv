#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# [--ppa=]* [--uri=]* [--suite=]* [--component=]* [_components=]* [--signed-by=]* [--pkg=]* [--cmd=*] [--check]
binstall.$(path.basename.part $0 1) \
         --pkg=$(path.basename "$0")
# post install
sudo groupadd fuse --system --users ${USER}
getent fuse ${USER} | grep --silent --fixed-strings ${USER} && >&2 echo "'${USER}' successfully added to group 'fuse'"

