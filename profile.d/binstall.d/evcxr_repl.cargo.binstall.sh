#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh
# https://github.com/evcxr/evcxr/blob/main/evcxr_repl/README.md
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$(realpath -Lm "$0")") "$@"


