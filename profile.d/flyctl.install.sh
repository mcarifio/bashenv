#!/usr/bin/env bash
set -Eeuo pipefail

install() (
    install.asdf "$@" && install.check $1 || return $(u.error "Could not install $1")
)
install $(path.basename ${BASH_SOURCE}) https://github.com/chessmango/asdf-flyctl.git "$@"
