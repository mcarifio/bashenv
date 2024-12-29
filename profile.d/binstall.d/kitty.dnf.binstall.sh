#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh

_kind=$(path.basename.part "$0" 1)
_pkg=$(path.basename "$(realpath -Lm "$0")")
binstalld.dispatch --kind=${_kind} \
                   --pkg=${_pkg} \
                   "$@"


