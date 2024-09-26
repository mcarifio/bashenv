#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh

exit $(u.error "need a url") 1

binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$0") "$@"
