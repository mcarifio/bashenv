#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# [--import=]* [--repo=]* [--copr=]* [--pkg=]* [--cmd=]*
binstall.$(path.basename.part $0 1) \
         --pkg=python-tkinter \
         --pkg=$(path.basename "$0") \
         "$@"
# post install





