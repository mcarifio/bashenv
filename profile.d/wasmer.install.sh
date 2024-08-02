#!/usr/bin/env bash
set -Eeuo pipefail

# wasmer.install.sh installs rust package `wasmer-cli` on all platforms.
install() (
    # local _id=$(os-release.id)
    # assume rust installed with rustup; rustup and cargo on PATH
    install.cargo wasmer-cli --features singlepass,cranelift
    install.check wasmer
)

install "$@"

