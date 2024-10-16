#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh

# See also openssh-server.dnf.install.sh
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$(realpath -Lm "$0")") --cmd=ssh "$@"



