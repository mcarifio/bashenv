#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh

post.install() (
    sudo ln -s /var/lib/snapd/snap /snap || true
    sudo systemctl enable --now snapd.socket
)

binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$(realpath -Lm "$0")") --postinstall=post.install "$@"


