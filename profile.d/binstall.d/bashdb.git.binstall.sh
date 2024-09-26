#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh
binstall.dnf --pkg=git autoconf automake texinfo texi2html make
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$0") https://github.com/rocky/bashdb "$@" "$@"

