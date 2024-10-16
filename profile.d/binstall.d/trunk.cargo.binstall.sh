#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh

# trunk.install.sh will install the yew support cli trunk, see https://yew.rs/docs/getting-started/introduction
rustup target add wasm32-unknown-unknown
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$(realpath -Lm "$0")") "$@"


