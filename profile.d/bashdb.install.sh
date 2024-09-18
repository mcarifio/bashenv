#!/usr/bin/env bash
set -Eeuo pipefail

install() (
    dnf install git autoconf automake texinfo || true
    git clone https://github.com/rocky/bashdb /tmp/bashdb
    cd /tmp/bashdb
    ./autogen.sh
    make
    sudo make install
    bashdb --version && rm -rf /tmp/bashdb || return $(u.error "bashdb failed, sources in /tmp/bashdb")    
)

install "$@"
