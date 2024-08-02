#!/usr/bin/env bash
set -Eeuo pipefail

# trunk.install.sh will install the yew support cli trunk, see https://yew.rs/docs/getting-started/introduction

install() (
    rustup target add wasm32-unknown-unknown
    cargo.install "$@"
    cargo.check $1
)

install $(path.basename ${BASH_SOURCE}) "$@"


