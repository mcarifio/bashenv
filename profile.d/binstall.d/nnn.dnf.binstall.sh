#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh
# nnn --version returns status 1(!)
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$0") --cmd=true "$@"


