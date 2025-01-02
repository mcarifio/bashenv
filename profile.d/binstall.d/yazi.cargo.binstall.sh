#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh
_pkg=$(path.basename "$(realpath -Lm "$0")")
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=${_pkg}-fm --pkg=${_pkg}-cli "$@"


