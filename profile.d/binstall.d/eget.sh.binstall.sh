#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh
# eget installed in $PWD so move to ~/.local/bin
( cd ~/.local/bin; binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$(realpath -Lm "$0")") --url="https://zyedidia.github.io/eget.sh" "$@" )


