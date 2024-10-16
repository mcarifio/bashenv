#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$(realpath -Lm "$0")") --url="https://github.com/asdf-community/asdf-duckdb.git" "$@"


