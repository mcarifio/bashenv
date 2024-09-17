#!/usr/bin/env bash
set -Eeuo pipefail

install() (
    local _crates=${1:-}; shift
    [[ -r "${_crates}" ]] && install.rustup "$@" <(sed '/^\s*#/d' "${_crates}") || install.rustup "$@"
)



install --home="~/opt/cargo" "~/opt/asdf/current/.default-cargo-crates"

