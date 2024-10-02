#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh

post.install() (
    echo "${FUNCNAME}@${0}:${LINENO}: tbs starting systemd itself" >&2
)

binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$0") --postinstall=post.install "$@"


