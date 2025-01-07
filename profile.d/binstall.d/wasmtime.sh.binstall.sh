#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --url= --pkg= --cmd=
binstall.$(path.basename.part $0 1) \
         --pkg=$(path.basename "$0") \
         --url="https://wasmtime.dev/install.sh" \ # -- arguments for script here \
         "$@"
# post install
