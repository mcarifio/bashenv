#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh
binstalld.dispatch --kind=$(path.basename.part "$0" 1) \
		   --import=https://packages.microsoft.com/keys/microsoft.asc \
                   --add-repo=https://packages.microsoft.com/yumrepos/edge \
                   --pkg=$(path.basename "$(realpath -Lm "$0")") \
		   "$@"


