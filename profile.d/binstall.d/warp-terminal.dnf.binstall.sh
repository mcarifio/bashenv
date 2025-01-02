#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh

# install the rpm directly from the internet
_rpm="https://releases.warp.dev/stable/v0.2024.12.18.08.02.stable_03/warp-terminal-v0.2024.12.18.08.02.stable_03-1.x86_64.rpm"
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg="${_rpm}" "$@"


