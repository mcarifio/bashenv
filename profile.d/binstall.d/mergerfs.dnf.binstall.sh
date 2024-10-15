#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=https://github.com/trapexit/mergerfs/releases/download/2.40.2/mergerfs-2.40.2-1.fc40.x86_64.rpm "$@"


