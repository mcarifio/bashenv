#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh

post.install() (
    sudo systemctl enable --now sshd
)

# installing the server gets the client as well. This might not always be desired.
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$(realpath -Lm "$0")") --cmd=/usr/sbin/sshd --postinstall=post.install "$@"



