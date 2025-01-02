#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$(realpath -Lm "$0")")-stable --signed-by=https://packages.microsoft.com/keys/microsoft.asc --component=stable --component=main --uri=https://packages.microsoft.com/repos/edge "$@"


