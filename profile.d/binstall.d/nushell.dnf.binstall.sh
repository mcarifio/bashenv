#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh
# installs nu
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$0") "$@"


