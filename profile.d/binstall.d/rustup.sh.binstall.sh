#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh

post.install() {
    source ${HOME}/.cargo/env
}

binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$(realpath -Lm "$0")") --postinstall=post.install --url=https://sh.rustup.rs -- -y --no-modify-path --profile default "$@"


