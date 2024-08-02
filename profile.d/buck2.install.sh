#!/usr/bin/env bash
set -Eeuo pipefail

install() (
    set -Eeuo pipefail
    local _buck2=~/.local/bin/${1:?'expecting a name'}
    local _tmp=$(mktemp --suffix=.zst)
    curl -LJ --show-error --output ${_tmp} ${2:?'expecting a url'}
    zstd --decompress --no-progress ${_tmp}
    command install ${_tmp%%.zst} "${_buck2}"
    >&2 echo "installed '${_buck2}' from '$2'"
)    

install $(path.basename ${BASH_SOURCE}) "https://github.com/facebook/buck2/releases/download/latest/buck2-x86_64-unknown-linux-gnu.zst" "$@"

