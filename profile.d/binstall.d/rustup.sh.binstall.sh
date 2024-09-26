#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh

post.install() {
    source ${HOME}/.cargo/env
}

binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$0") --url=https://sh.rustup.rs --postinstall=post.install -- -y --no-modify-path --profile default "$@"


