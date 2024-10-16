#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh
# cargo install --git=https://github.com/astral-sh/rye rye
# binstalld.dispatch --kind=cargo --pkg=rye --git=https://github.com/astral-sh/rye
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$(realpath -Lm "$0")") "$@"


