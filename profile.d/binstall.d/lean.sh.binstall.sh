#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh

# TODO mike@carif.io: doesn't work
binstalld.dispatch --kind=$(path.basename.part "$0" 1) \
                   --pkg=$(path.basename "$(realpath -Lm "$0")") \
                   --url=https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh \
                   -- -y --no-modify-path "$@"




