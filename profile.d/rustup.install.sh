#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/install.lib.sh

# dispatch
# install() ( install.$(os.release ID) "$@"; )
install.rustup() (
    set -Eeuo pipefail
    # https://www.rust-lang.org/learn/get-started
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh # hate this
    # hardcode installation directory ugh
    path.add ~/.cargo/bin
    install.check rustup
    install.check cargo
    
    cargo install <(sed '/^\s*#/d' ~/opt/asdf/current/.default-cargo-crates)
)

install() (
    local _crates=${1:-}; shift
    [[ -r "${_crates}" ]] && install.rustup "$@" <(sed '/^\s*#/d' "${_crates}") || install.rustup "$@"
)



install "~/opt/asdf/current/.default-cargo-crates"

