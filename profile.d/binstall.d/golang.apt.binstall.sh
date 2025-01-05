#!/usr/bin/env bash
set -Eeuo pipefail
source $(u.here)/../$(path.basename.part $0 2).source.sh
# --pkg= --cmd=
binstall.$(path.basename.part $0 1) \
         --pkg=$(path.basename "$0") \
         "$@"
# post install
[[ -d ~/go ]] || mkdir -v ~/go
u.have go || { >&2 echo "$0 could not find go"; return 1; }
go env
binstall.go --url="github.com/posener/complete/gocomplete@latest"
