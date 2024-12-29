#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh

# https://ghostty.org/docs/install/binary#fedora
# note that --pkg, --copr are passed along to binstall.dnf()
binstalld.dispatch --kind=$(path.basename.part "$0" 1) \
                   --pkg=$(path.basename "$(realpath -Lm "$0")") \
                   --copr=pgdev/ghostty \
                   "$@"


