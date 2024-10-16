#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh
binstall.dnf --pkg=clang lld # needed by buck2 for cpp projects
binstalld.dispatch --kind=$(path.basename.part "$0" 1) --pkg=$(path.basename "$(realpath -Lm "$0")") --url="https://github.com/facebook/buck2/releases/download/latest/buck2-x86_64-unknown-linux-gnu.zst" "$@"
