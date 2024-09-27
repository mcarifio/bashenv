#!/usr/bin/env bash
source $(u.here)/binstalld.lib.sh

_binstall() (
    u.have git || install.dnf git
    u.have asdf && return $(u.error "$0: you have asdf at $(type -p asdf)")
    git clone https://github.com/asdf-vm/asdf.git ~/opt/asdf/current --branch v0.14.1
    source $(realpath -Lm $(u.here)/..)/$(path.basename $0).source.sh"
    binstall.check asdf
)
_binstall "$@"

