#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh

# hack so that cargo can build nvrs
u.have apt && $(u.here)/librust-openssl-dev.apt.binstall.sh

binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$(realpath -Lm "$0")") --all-features "$@"


