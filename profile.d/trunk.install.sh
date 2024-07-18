#!/usr/bin/env bash
# trunk.install.sh will install the yew support cli trunk, see https://yew.rs/docs/getting-started/introduction

# dispatch
# install() ( install.$(os.release ID) "$@"; )
install() (
    set -Eeuo pipefail
    rustup target add wasm32-unknown-unknown
    cargo install trunk
)

install "$@"

