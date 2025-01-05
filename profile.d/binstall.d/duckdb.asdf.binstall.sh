#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --url= --version= [--pkg=]+ [--cmd=]*
binstall.$(path.basename.part $0 1) \
         --url="https://github.com/asdf-community/asdf-duckdb.git" "$@" \
         --pkg=$(path.basename "$0") \
         "$@"
