#!/usr/bin/env bash
set -Eeuo pipefail

install() (
    install.pip "$@"
    # kivy is "just" a python package, no exe.
    install.check p4a
)

install $(path.basename ${BASH_SOURCE}) python-for-android "$@"

