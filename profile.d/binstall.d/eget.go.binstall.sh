#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/binstalld.lib.sh

_kind=$(path.basename.part "$0" 1)
_pkg=$(path.basename "$(realpath -Lm "$0")")
_url="github.com/zyedidia/eget@latest"

binstalld.dispatch --kind=${_kind} \
                   --pkg=${_pkg} \
                   --url="${_url}" \
                   "$@"



